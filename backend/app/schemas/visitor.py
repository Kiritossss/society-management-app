import uuid
from datetime import datetime

from pydantic import BaseModel, field_validator

from app.models.visitor import VisitPurpose, VisitStatus


class VisitorPreApprove(BaseModel):
    """Resident pre-approves a visitor before they arrive."""
    visitor_name: str
    visitor_phone: str | None = None
    visitor_count: int = 1
    purpose: VisitPurpose = VisitPurpose.GUEST
    vehicle_number: str | None = None
    expected_at: datetime | None = None
    notes: str | None = None

    @field_validator("visitor_name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Visitor name cannot be blank")
        return v.strip()

    @field_validator("visitor_count")
    @classmethod
    def count_positive(cls, v: int) -> int:
        if v < 1 or v > 50:
            raise ValueError("Visitor count must be between 1 and 50")
        return v


class VisitorLogEntry(BaseModel):
    """Support staff logs a visitor arrival."""
    visitor_name: str
    visitor_phone: str | None = None
    visitor_count: int = 1
    purpose: VisitPurpose = VisitPurpose.GUEST
    vehicle_number: str | None = None
    unit_id: uuid.UUID | None = None
    resident_id: uuid.UUID | None = None
    notes: str | None = None

    @field_validator("visitor_name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Visitor name cannot be blank")
        return v.strip()

    @field_validator("visitor_count")
    @classmethod
    def count_positive(cls, v: int) -> int:
        if v < 1 or v > 50:
            raise ValueError("Visitor count must be between 1 and 50")
        return v


class VisitorStatusUpdate(BaseModel):
    """Resident approves/denies, or staff checks out a visitor."""
    status: VisitStatus


class VisitorResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    society_id: str
    unit_id: uuid.UUID | None
    resident_id: uuid.UUID | None
    visitor_name: str
    visitor_phone: str | None
    visitor_count: int
    purpose: VisitPurpose
    vehicle_number: str | None
    notes: str | None
    status: VisitStatus
    pre_approved_by_id: uuid.UUID | None
    checked_in_by_id: uuid.UUID | None
    expected_at: datetime | None
    checked_in_at: datetime | None
    checked_out_at: datetime | None
    created_at: datetime
    updated_at: datetime
