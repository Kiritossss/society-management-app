import uuid
from datetime import datetime

from pydantic import BaseModel, field_validator

from app.models.complaint import ComplaintCategory, ComplaintStatus


class ComplaintCreate(BaseModel):
    title: str
    description: str
    category: ComplaintCategory = ComplaintCategory.OTHER
    image_url: str | None = None

    @field_validator("image_url")
    @classmethod
    def validate_image_url(cls, v: str | None) -> str | None:
        if v is None or not v.strip():
            return None
        v = v.strip()
        if not v.startswith(("http://", "https://")):
            raise ValueError("Image URL must start with http:// or https://")
        if len(v) > 500:
            raise ValueError("Image URL must be 500 characters or fewer")
        return v

    @field_validator("title")
    @classmethod
    def title_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Title cannot be blank")
        if len(v) > 255:
            raise ValueError("Title must be 255 characters or fewer")
        return v.strip()

    @field_validator("description")
    @classmethod
    def description_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Description cannot be blank")
        return v.strip()


class ComplaintStatusUpdate(BaseModel):
    status: ComplaintStatus


class ComplaintResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    society_id: str
    raised_by_id: uuid.UUID
    title: str
    description: str
    category: ComplaintCategory
    status: ComplaintStatus
    image_url: str | None
    resolved_at: datetime | None
    created_at: datetime
    updated_at: datetime
