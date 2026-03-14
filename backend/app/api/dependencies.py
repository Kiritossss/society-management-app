import uuid
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError
from sqlalchemy.orm import Session

from app.core.security import decode_access_token
from app.crud.crud_user import get_user_by_id
from app.db.session import get_db
from app.models.user import User, UserRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Annotated[Session, Depends(get_db)],
) -> User:
    """Decode JWT, validate claims, and return the authenticated User."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_access_token(token)
        user_id: str | None = payload.get("sub")
        society_id: str | None = payload.get("society_id")
        if not user_id or not society_id:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = get_user_by_id(db, uuid.UUID(society_id), uuid.UUID(user_id))
    if not user or not user.is_active:
        raise credentials_exception
    return user


def require_roles(*roles: UserRole):
    """Dependency factory — restricts endpoint to users with the given roles."""
    def _check(current_user: Annotated[User, Depends(get_current_user)]) -> User:
        if current_user.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action",
            )
        return current_user
    return _check


# Pre-built role guards (import these directly in endpoint files)
require_admin = require_roles(UserRole.ADMIN)
require_committee = require_roles(UserRole.ADMIN, UserRole.COMMITTEE)
require_support_staff = require_roles(UserRole.ADMIN, UserRole.COMMITTEE, UserRole.SUPPORT_STAFF)
require_member = require_roles(UserRole.ADMIN, UserRole.COMMITTEE, UserRole.SUPPORT_STAFF, UserRole.MEMBER)
