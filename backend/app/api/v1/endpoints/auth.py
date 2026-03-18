from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token
from app.crud.crud_society import create_society, get_society_by_email, get_society_by_id
from app.crud.crud_user import (
    activate_user,
    authenticate_user,
    create_user,
    get_societies_for_email,
    get_user_by_email,
    get_user_by_invite_token,
)
from app.db.session import get_db
from app.schemas.society import SocietyCreate, SocietyResponse
from app.schemas.user import (
    ActivateAccount,
    EmailLookup,
    SocietyLookupResponse,
    TokenResponse,
    UserLogin,
    UserRegister,
    UserResponse,
)

router = APIRouter(prefix="/auth", tags=["Authentication"])

_SOCIETY_ID = Query(..., min_length=5, max_length=5, pattern="^[A-Z]{5}$", description="5-letter society code (e.g. AAKXZ)")


@router.post("/society/register", response_model=SocietyResponse, status_code=status.HTTP_201_CREATED)
def register_society(data: SocietyCreate, db: Session = Depends(get_db)):
    """Onboard a new society. Contact email must be globally unique."""
    if get_society_by_email(db, data.contact_email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A society with this contact email already exists",
        )
    return create_society(db, data)


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register_user(
    data: UserRegister,
    society_id: str = _SOCIETY_ID,
    db: Session = Depends(get_db),
):
    """
    Bootstrap-only: register the first admin user in a society.
    After the first user, all members must be added via admin invite.
    """
    society = get_society_by_id(db, society_id)
    if not society or not society.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Society not found")

    if get_user_by_email(db, society_id, data.email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered in this society",
        )
    return create_user(db, society_id, data)


@router.post("/activate", response_model=TokenResponse)
def activate_account(data: ActivateAccount, db: Session = Depends(get_db)):
    """
    Resident activates their account using the invite token from admin.
    Sets their password and returns a JWT — they are immediately logged in.
    """
    user = get_user_by_invite_token(db, data.invite_token)
    if not user or user.email.lower() != data.email.lower():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Invalid invite token or email",
        )
    if user.is_activated:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Account is already activated",
        )
    if user.invite_expires_at and user.invite_expires_at < datetime.now(timezone.utc):
        raise HTTPException(
            status_code=status.HTTP_410_GONE,
            detail="Invite token has expired — ask your admin to resend the invite",
        )

    user = activate_user(db, user, data.password)

    token = create_access_token(
        subject={
            "sub": str(user.id),
            "society_id": user.society_id,
            "role": user.role,
        }
    )
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))


@router.post("/lookup", response_model=SocietyLookupResponse)
def lookup_societies(data: EmailLookup, db: Session = Depends(get_db)):
    """
    Given an email, return the list of societies that email belongs to.
    Used by the mobile app to let multi-society users pick which society to log into.
    Does not reveal passwords or tokens — only society names.
    """
    societies = get_societies_for_email(db, data.email)
    # Always return 200 with an empty list (don't reveal whether an email exists)
    return SocietyLookupResponse(societies=societies)


@router.post("/login", response_model=TokenResponse)
def login(
    data: UserLogin,
    society_id: str = _SOCIETY_ID,
    db: Session = Depends(get_db),
):
    """Authenticate a user and return a JWT access token."""
    user = authenticate_user(db, society_id, data.email, data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")

    token = create_access_token(
        subject={
            "sub": str(user.id),
            "society_id": user.society_id,
            "role": user.role,
        }
    )
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))
