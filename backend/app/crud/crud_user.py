import secrets
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.user import User, UserRole
from app.models.unit import Unit
from app.schemas.user import AdminCreateUser, UserRegister


def _generate_invite_token() -> str:
    """Generate a URL-safe invite token (22 chars)."""
    return secrets.token_urlsafe(16)


def get_user_by_email(db: Session, society_id: str, email: str) -> User | None:
    """Fetch a user scoped to a specific society (multi-tenant safe)."""
    return (
        db.query(User)
        .filter(User.society_id == society_id, User.email == email)
        .first()
    )


def get_user_by_id(db: Session, society_id: str, user_id: uuid.UUID) -> User | None:
    return (
        db.query(User)
        .filter(User.society_id == society_id, User.id == user_id)
        .first()
    )


def get_user_by_invite_token(db: Session, invite_token: str) -> User | None:
    """Find a user by their invite token."""
    return db.query(User).filter(User.invite_token == invite_token).first()


def get_societies_for_email(db: Session, email: str) -> list[dict]:
    """Return all societies that have a user with this email."""
    users = (
        db.query(User)
        .filter(User.email == email, User.is_active == True)
        .all()
    )
    return [
        {"society_id": u.society_id, "society_name": u.society.name}
        for u in users
    ]


def create_user(db: Session, society_id: str, data: UserRegister) -> User:
    """Admin bootstrap: first user in a society becomes ADMIN with full password."""
    existing_count = db.query(User).filter(User.society_id == society_id).count()
    role = UserRole.ADMIN if existing_count == 0 else UserRole.MEMBER

    user = User(
        society_id=society_id,
        email=data.email,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        role=role,
        is_activated=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def get_users(db: Session, society_id: str, skip: int = 0, limit: int = 50) -> list[User]:
    return (
        db.query(User)
        .filter(User.society_id == society_id)
        .order_by(User.full_name)
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_user_admin(db: Session, society_id: str, data: AdminCreateUser) -> User:
    """Admin creates a member — no password, generates invite token instead."""
    user = User(
        society_id=society_id,
        email=data.email,
        hashed_password="!",  # locked — cannot login until activated
        full_name=data.full_name,
        role=data.role,
        unit_id=data.unit_id,
        is_activated=False,
        invite_token=_generate_invite_token(),
        invite_expires_at=datetime.now(timezone.utc) + timedelta(days=7),
    )
    db.add(user)
    # Mark unit as occupied if assigned
    if data.unit_id:
        unit = db.query(Unit).filter(Unit.id == data.unit_id, Unit.society_id == society_id).first()
        if unit:
            unit.is_occupied = True
    db.commit()
    db.refresh(user)
    return user


def regenerate_invite_token(db: Session, user: User) -> User:
    """Regenerate invite token for a member who hasn't activated yet."""
    user.invite_token = _generate_invite_token()
    user.invite_expires_at = datetime.now(timezone.utc) + timedelta(days=7)
    db.commit()
    db.refresh(user)
    return user


def activate_user(db: Session, user: User, password: str) -> User:
    """Activate an invited user — set their password and clear the invite token."""
    user.hashed_password = hash_password(password)
    user.is_activated = True
    user.invite_token = None
    user.invite_expires_at = None
    db.commit()
    db.refresh(user)
    return user


def assign_unit(db: Session, user: User, unit_id: uuid.UUID | None, society_id: str) -> User:
    """Assign or reassign a user to a unit. Pass None to unassign."""
    # Free the old unit
    if user.unit_id:
        old_unit = db.query(Unit).filter(Unit.id == user.unit_id).first()
        if old_unit:
            other_residents = (
                db.query(User)
                .filter(User.unit_id == user.unit_id, User.id != user.id)
                .count()
            )
            if other_residents == 0:
                old_unit.is_occupied = False

    user.unit_id = unit_id

    if unit_id:
        new_unit = db.query(Unit).filter(Unit.id == unit_id, Unit.society_id == society_id).first()
        if new_unit:
            new_unit.is_occupied = True

    db.commit()
    db.refresh(user)
    return user


def deactivate_user(db: Session, user: User) -> User:
    user.is_active = False
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(db: Session, society_id: str, email: str, password: str) -> User | None:
    user = get_user_by_email(db, society_id, email)
    if not user or not user.is_activated:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user
