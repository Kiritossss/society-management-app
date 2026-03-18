import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.dependencies import require_admin
from app.crud.crud_unit import get_unit_by_id
from app.crud.crud_user import (
    assign_unit,
    create_user_admin,
    deactivate_user,
    get_user_by_email,
    get_user_by_id,
    get_users,
    regenerate_invite_token,
)
from app.db.session import get_db
from app.models.user import User
from app.schemas.user import AdminCreateUser, AssignUnit, MemberInviteResponse, UserResponse

router = APIRouter(prefix="/members", tags=["Members"])


@router.post("/", response_model=MemberInviteResponse, status_code=status.HTTP_201_CREATED)
def add_member(
    data: AdminCreateUser,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    """
    Admin adds a member to the society. No password needed —
    an invite token is generated for the member to activate their account.
    Share this token with the member (SMS, WhatsApp, email).
    """
    existing = get_user_by_email(db, current_user.society_id, data.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this email already exists in this society",
        )

    if data.unit_id:
        unit = get_unit_by_id(db, current_user.society_id, data.unit_id)
        if not unit:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Unit not found in this society",
            )

    return create_user_admin(db, society_id=current_user.society_id, data=data)


@router.get("/", response_model=list[UserResponse])
def list_members(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=100),
):
    """Admin lists all members of the society."""
    return get_users(db, society_id=current_user.society_id, skip=skip, limit=limit)


@router.post("/{user_id}/reinvite", response_model=MemberInviteResponse)
def reinvite_member(
    user_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    """Regenerate invite token for a member who hasn't activated yet."""
    user = get_user_by_id(db, current_user.society_id, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    if user.is_activated:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User is already activated — cannot reinvite",
        )
    return regenerate_invite_token(db, user)


@router.patch("/{user_id}/unit", response_model=UserResponse)
def assign_member_unit(
    user_id: uuid.UUID,
    data: AssignUnit,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    """Admin assigns or reassigns a member to a unit."""
    user = get_user_by_id(db, current_user.society_id, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    if data.unit_id:
        unit = get_unit_by_id(db, current_user.society_id, data.unit_id)
        if not unit:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Unit not found in this society",
            )

    return assign_unit(db, user, data.unit_id, current_user.society_id)


@router.patch("/{user_id}/deactivate", response_model=UserResponse)
def deactivate_member(
    user_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    """Admin deactivates a member."""
    user = get_user_by_id(db, current_user.society_id, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    if user.id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot deactivate yourself",
        )
    return deactivate_user(db, user)
