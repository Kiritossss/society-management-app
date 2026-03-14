import uuid

from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.user import User, UserRole
from app.schemas.user import UserRegister


def get_user_by_email(db: Session, society_id: uuid.UUID, email: str) -> User | None:
    """Fetch a user scoped to a specific society (multi-tenant safe)."""
    return (
        db.query(User)
        .filter(User.society_id == society_id, User.email == email)
        .first()
    )


def get_user_by_id(db: Session, society_id: uuid.UUID, user_id: uuid.UUID) -> User | None:
    return (
        db.query(User)
        .filter(User.society_id == society_id, User.id == user_id)
        .first()
    )


def create_user(db: Session, society_id: uuid.UUID, data: UserRegister) -> User:
    user = User(
        society_id=society_id,
        email=data.email,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        role=data.role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(db: Session, society_id: uuid.UUID, email: str, password: str) -> User | None:
    user = get_user_by_email(db, society_id, email)
    if not user or not verify_password(password, user.hashed_password):
        return None
    return user
