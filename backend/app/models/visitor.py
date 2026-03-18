import uuid
from datetime import datetime
from enum import Enum

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from app.db.base_class import Base


class VisitPurpose(str, Enum):
    GUEST = "guest"
    DELIVERY = "delivery"
    CAB = "cab"
    SERVICE = "service"
    OTHER = "other"


class VisitStatus(str, Enum):
    PRE_APPROVED = "pre_approved"
    PENDING = "pending"
    APPROVED = "approved"
    DENIED = "denied"
    CHECKED_IN = "checked_in"
    CHECKED_OUT = "checked_out"


class VisitorLog(Base):
    __tablename__ = "visitor_logs"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    # Multi-tenancy
    society_id: Mapped[str] = mapped_column(
        String(5),
        ForeignKey("societies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    # Which unit the visitor is visiting
    unit_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("units.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    # Which resident the visitor is visiting
    resident_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )

    # Visitor details
    visitor_name: Mapped[str] = mapped_column(String(200), nullable=False)
    visitor_phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    visitor_count: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    purpose: Mapped[VisitPurpose] = mapped_column(
        String(50), nullable=False, default=VisitPurpose.GUEST
    )
    vehicle_number: Mapped[str | None] = mapped_column(String(20), nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Status tracking
    status: Mapped[VisitStatus] = mapped_column(
        String(50), nullable=False, default=VisitStatus.PENDING
    )

    # Who did what
    pre_approved_by_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    checked_in_by_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

    # Timestamps
    expected_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    checked_in_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    checked_out_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    # Relationships
    unit: Mapped["Unit"] = relationship("Unit", foreign_keys=[unit_id])  # noqa: F821
    resident: Mapped["User"] = relationship("User", foreign_keys=[resident_id])  # noqa: F821
    pre_approved_by: Mapped["User"] = relationship("User", foreign_keys=[pre_approved_by_id])  # noqa: F821
    checked_in_by: Mapped["User"] = relationship("User", foreign_keys=[checked_in_by_id])  # noqa: F821

    def __repr__(self) -> str:
        return f"<VisitorLog id={self.id} visitor={self.visitor_name} status={self.status}>"
