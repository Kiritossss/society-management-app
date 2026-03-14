import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, require_committee
from app.crud.crud_complaint import (
    create_complaint,
    get_complaint_by_id,
    get_complaints,
    update_complaint_status,
)
from app.db.session import get_db
from app.models.user import User
from app.schemas.complaint import ComplaintCreate, ComplaintResponse, ComplaintStatusUpdate

router = APIRouter(prefix="/complaints", tags=["Complaints"])


@router.post("/", response_model=ComplaintResponse, status_code=status.HTTP_201_CREATED)
def raise_complaint(
    data: ComplaintCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Any authenticated member can raise a complaint."""
    return create_complaint(
        db,
        society_id=current_user.society_id,
        raised_by_id=current_user.id,
        data=data,
    )


@router.get("/", response_model=list[ComplaintResponse])
def list_complaints(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    skip: int = 0,
    limit: int = 50,
):
    """
    Committee/Admin: all complaints in the society.
    Member: only their own complaints.
    """
    return get_complaints(
        db,
        society_id=current_user.society_id,
        requesting_user_id=current_user.id,
        requesting_user_role=current_user.role,
        skip=skip,
        limit=limit,
    )


@router.get("/{complaint_id}", response_model=ComplaintResponse)
def get_complaint(
    complaint_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    complaint = get_complaint_by_id(db, current_user.society_id, complaint_id)
    if not complaint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")

    # Members can only view their own complaints
    from app.models.user import UserRole
    if current_user.role == UserRole.MEMBER and complaint.raised_by_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    return complaint


@router.patch("/{complaint_id}/status", response_model=ComplaintResponse)
def update_status(
    complaint_id: uuid.UUID,
    data: ComplaintStatusUpdate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_committee)],
):
    """Only Committee/Admin can update complaint status."""
    complaint = get_complaint_by_id(db, current_user.society_id, complaint_id)
    if not complaint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")
    return update_complaint_status(db, complaint, data)
