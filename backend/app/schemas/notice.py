import uuid
from datetime import datetime

from pydantic import BaseModel, field_validator

from app.models.notice import NoticePriority


class NoticeCreate(BaseModel):
    title: str
    body: str
    priority: NoticePriority = NoticePriority.NORMAL
    is_pinned: bool = False
    image_url: str | None = None

    @field_validator("title")
    @classmethod
    def title_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Title cannot be blank")
        if len(v) > 255:
            raise ValueError("Title must be 255 characters or fewer")
        return v.strip()

    @field_validator("body")
    @classmethod
    def body_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Body cannot be blank")
        return v.strip()


class NoticeUpdate(BaseModel):
    title: str | None = None
    body: str | None = None
    priority: NoticePriority | None = None
    is_pinned: bool | None = None
    image_url: str | None = None

    @field_validator("title")
    @classmethod
    def title_not_empty(cls, v: str | None) -> str | None:
        if v is None:
            return None
        if not v.strip():
            raise ValueError("Title cannot be blank")
        if len(v) > 255:
            raise ValueError("Title must be 255 characters or fewer")
        return v.strip()

    @field_validator("body")
    @classmethod
    def body_not_empty(cls, v: str | None) -> str | None:
        if v is None:
            return None
        if not v.strip():
            raise ValueError("Body cannot be blank")
        return v.strip()


class NoticeResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    society_id: str
    posted_by_id: uuid.UUID
    title: str
    body: str
    priority: NoticePriority
    is_pinned: bool
    image_url: str | None
    created_at: datetime
    updated_at: datetime
