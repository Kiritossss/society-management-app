import uuid
from datetime import datetime

from pydantic import BaseModel, field_validator


class CommentCreate(BaseModel):
    body: str

    @field_validator("body")
    @classmethod
    def body_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Comment body cannot be blank")
        if len(v) > 2000:
            raise ValueError("Comment must be 2000 characters or fewer")
        return v.strip()


class CommentResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    complaint_id: uuid.UUID
    user_id: uuid.UUID
    user_name: str
    body: str
    created_at: datetime
