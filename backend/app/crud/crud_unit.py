import uuid

from sqlalchemy.orm import Session

from app.models.unit import Unit
from app.schemas.unit import UnitCreate, UnitUpdate


def get_unit_by_id(db: Session, society_id: str, unit_id: uuid.UUID) -> Unit | None:
    return (
        db.query(Unit)
        .filter(Unit.society_id == society_id, Unit.id == unit_id)
        .first()
    )


def get_units(db: Session, society_id: str, skip: int = 0, limit: int = 50) -> list[Unit]:
    return (
        db.query(Unit)
        .filter(Unit.society_id == society_id)
        .order_by(Unit.block_name, Unit.floor_number, Unit.unit_number)
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_unit(db: Session, society_id: str, data: UnitCreate) -> Unit:
    unit = Unit(
        society_id=society_id,
        block_name=data.block_name,
        floor_number=data.floor_number,
        unit_number=data.unit_number,
        unit_type=data.unit_type,
        area_sqft=data.area_sqft,
    )
    db.add(unit)
    db.commit()
    db.refresh(unit)
    return unit


def create_units_bulk(db: Session, society_id: str, units: list[UnitCreate]) -> list[Unit]:
    db_units = [
        Unit(
            society_id=society_id,
            block_name=u.block_name,
            floor_number=u.floor_number,
            unit_number=u.unit_number,
            unit_type=u.unit_type,
            area_sqft=u.area_sqft,
        )
        for u in units
    ]
    db.add_all(db_units)
    db.commit()
    for u in db_units:
        db.refresh(u)
    return db_units


def update_unit(db: Session, unit: Unit, data: UnitUpdate) -> Unit:
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(unit, field, value)
    db.commit()
    db.refresh(unit)
    return unit


def delete_unit(db: Session, unit: Unit) -> None:
    if unit.is_occupied:
        raise ValueError("Cannot delete an occupied unit. Reassign residents first.")
    db.delete(unit)
    db.commit()
