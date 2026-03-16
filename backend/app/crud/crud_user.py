import uuid

from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.user import User, UserRole
from app.models.unit import Unit
from app.schemas.user import AdminCreateUser, UserRegister


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
    """Public registration. First user in a society becomes ADMIN; others become MEMBER."""
    # Bootstrap: if no users exist yet in this society, make this one the admin
    existing_count = db.query(User).filter(User.society_id == society_id).count()
    role = UserRole.ADMIN if existing_count == 0 else UserRole.MEMBER

    user = User(
        society_id=society_id,
        email=data.email,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        role=role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def get_users(db: Session, society_id: uuid.UUID, skip: int = 0, limit: int = 50) -> list[User]:
    return (
        db.query(User)
        .filter(User.society_id == society_id)
        .order_by(User.full_name)
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_user_admin(db: Session, society_id: uuid.UUID, data: AdminCreateUser) -> User:
    """Admin creates a user with specified role and optional unit assignment."""
    user = User(
        society_id=society_id,
        email=data.email,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        role=data.role,
        unit_id=data.unit_id,
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


def assign_unit(db: Session, user: User, unit_id: uuid.UUID | None, society_id: uuid.UUID) -> User:
    """Assign or reassign a user to a unit. Pass None to unassign."""
    # Free the old unit
    if user.unit_id:
        old_unit = db.query(Unit).filter(Unit.id == user.unit_id).first()
        if old_unit:
            # Check if any other residents remain
            other_residents = (
                db.query(User)
                .filter(User.unit_id == user.unit_id, User.id != user.id)
                .count()
            )
            if other_residents == 0:
                old_unit.is_occupied = False

    user.unit_id = unit_id

    # Mark the new unit as occupied
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


def authenticate_user(db: Session, society_id: uuid.UUID, email: str, password: str) -> User | None:
    user = get_user_by_email(db, society_id, email)
    if not user or not verify_password(password, user.hashed_password):
        return None
    return user
