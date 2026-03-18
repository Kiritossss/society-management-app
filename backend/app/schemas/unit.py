import uuid
from datetime import datetime

from pydantic import BaseModel, field_validator


class UnitCreate(BaseModel):
    block_name: str | None = None
    floor_number: str | None = None
    unit_number: str
    unit_type: str | None = None
    area_sqft: float | None = None

    @field_validator("unit_number")
    @classmethod
    def unit_number_valid(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Unit number cannot be blank")
        if len(v) > 50:
            raise ValueError("Unit number must be 50 characters or fewer")
        return v.strip()

    @field_validator("block_name")
    @classmethod
    def clean_block_name(cls, v: str | None) -> str | None:
        if v is None or not v.strip():
            return None
        return v.strip()

    @field_validator("floor_number")
    @classmethod
    def clean_floor_number(cls, v: str | None) -> str | None:
        if v is None or not v.strip():
            return None
        return v.strip()

    @field_validator("area_sqft")
    @classmethod
    def area_positive(cls, v: float | None) -> float | None:
        if v is not None and v < 0:
            raise ValueError("Area must be a positive number")
        return v


class UnitUpdate(BaseModel):
    unit_type: str | None = None
    area_sqft: float | None = None
    is_occupied: bool | None = None

    @field_validator("area_sqft")
    @classmethod
    def area_positive(cls, v: float | None) -> float | None:
        if v is not None and v < 0:
            raise ValueError("Area must be a positive number")
        return v


class UnitResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    society_id: str
    block_name: str | None
    floor_number: str | None
    unit_number: str
    unit_type: str | None
    area_sqft: float | None
    is_occupied: bool
    created_at: datetime
    updated_at: datetime


class UnitBulkCreate(BaseModel):
    units: list[UnitCreate]

    @field_validator("units")
    @classmethod
    def limit_bulk_size(cls, v: list[UnitCreate]) -> list[UnitCreate]:
        if len(v) == 0:
            raise ValueError("At least one unit is required")
        if len(v) > 200:
            raise ValueError("Cannot create more than 200 units at once")
        return v
