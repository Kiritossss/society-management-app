import uuid
from datetime import datetime

from pydantic import BaseModel, EmailStr, field_validator

from app.models.user import UserRole


class UserRegister(BaseModel):
    """Used only for admin bootstrap (first user in a society)."""
    full_name: str
    email: EmailStr
    password: str

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v

    @field_validator("full_name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Full name cannot be blank")
        return v.strip()


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class AdminCreateUser(BaseModel):
    """Admin creates a member — no password needed. Invite token is auto-generated."""
    full_name: str
    email: EmailStr
    role: UserRole = UserRole.MEMBER
    unit_id: uuid.UUID | None = None

    @field_validator("full_name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Full name cannot be blank")
        return v.strip()


class ActivateAccount(BaseModel):
    """Resident activates their account using the invite token from admin."""
    email: EmailStr
    invite_token: str
    password: str

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v


class EmailLookup(BaseModel):
    """Look up which societies an email belongs to."""
    email: EmailStr


class AssignUnit(BaseModel):
    unit_id: uuid.UUID | None


class UserResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    society_id: str
    unit_id: uuid.UUID | None
    email: EmailStr
    full_name: str
    role: UserRole
    is_active: bool
    is_activated: bool
    created_at: datetime


class MemberInviteResponse(UserResponse):
    """Returned when admin creates a member — includes the one-time invite token."""
    invite_token: str | None


class SocietyLookupItem(BaseModel):
    society_id: str
    society_name: str


class SocietyLookupResponse(BaseModel):
    societies: list[SocietyLookupItem]


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
