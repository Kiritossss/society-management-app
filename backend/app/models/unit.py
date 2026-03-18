import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Index, String, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from app.db.base_class import Base


class Unit(Base):
    __tablename__ = "units"
    __table_args__ = (
        Index(
            "uq_unit_identity",
            "society_id",
            text("COALESCE(block_name, '')"),
            text("COALESCE(floor_number, '')"),
            "unit_number",
            unique=True,
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    society_id: Mapped[str] = mapped_column(
        String(5),
        ForeignKey("societies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    block_name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    floor_number: Mapped[str | None] = mapped_column(String(20), nullable=True)
    unit_number: Mapped[str] = mapped_column(String(50), nullable=False)
    unit_type: Mapped[str | None] = mapped_column(String(50), nullable=True)
    area_sqft: Mapped[float | None] = mapped_column(Float, nullable=True)
    is_occupied: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    # Relationships
    society: Mapped["Society"] = relationship("Society", back_populates="units")  # noqa: F821
    residents: Mapped[list["User"]] = relationship("User", back_populates="unit")  # noqa: F821

    def __repr__(self) -> str:
        parts = [self.unit_number]
        if self.block_name:
            parts.insert(0, self.block_name)
        if self.floor_number:
            parts.insert(-1, f"Floor {self.floor_number}")
        return f"<Unit {' / '.join(parts)}>"
