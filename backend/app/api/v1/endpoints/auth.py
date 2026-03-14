import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token
from app.crud.crud_society import create_society, get_society_by_email, get_society_by_id
from app.crud.crud_user import authenticate_user, create_user, get_user_by_email
from app.db.session import get_db
from app.schemas.society import SocietyCreate, SocietyResponse
from app.schemas.user import TokenResponse, UserLogin, UserRegister, UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


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
    society_id: uuid.UUID,
    data: UserRegister,
    db: Session = Depends(get_db),
):
    """Register a new user within a society. Email must be unique per society."""
    society = get_society_by_id(db, society_id)
    if not society or not society.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Society not found")

    if get_user_by_email(db, society_id, data.email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered in this society",
        )
    return create_user(db, society_id, data)


@router.post("/login", response_model=TokenResponse)
def login(
    society_id: uuid.UUID,
    data: UserLogin,
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
            "society_id": str(user.society_id),
            "role": user.role,
        }
    )
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))
