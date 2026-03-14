import uuid
from datetime import datetime

from pydantic import BaseModel, EmailStr


class SocietyCreate(BaseModel):
    name: str
    address: str
    contact_email: EmailStr


class SocietyResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    name: str
    address: str
    contact_email: EmailStr
    is_active: bool
    created_at: datetime
