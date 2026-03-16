import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.dependencies import require_admin
from app.crud.crud_unit import (
    create_unit,
    create_units_bulk,
    delete_unit,
    get_unit_by_id,
    get_units,
    update_unit,
)
from app.db.session import get_db
from app.models.user import User
from app.schemas.unit import UnitBulkCreate, UnitCreate, UnitResponse, UnitUpdate

router = APIRouter(prefix="/units", tags=["Units"])


@router.post("/", response_model=UnitResponse, status_code=status.HTTP_201_CREATED)
def create_single_unit(
    data: UnitCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    """Admin creates a single unit in the society layout."""
    return create_unit(db, society_id=current_user.society_id, data=data)


@router.post("/bulk", response_model=list[UnitResponse], status_code=status.HTTP_201_CREATED)
def create_bulk_units(
    data: UnitBulkCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    """Admin creates multiple units at once (max 200)."""
    return create_units_bulk(db, society_id=current_user.society_id, units=data.units)


@router.get("/", response_model=list[UnitResponse])
def list_units(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=100),
):
    """Admin lists all units in the society."""
    return get_units(db, society_id=current_user.society_id, skip=skip, limit=limit)


@router.get("/{unit_id}", response_model=UnitResponse)
def get_single_unit(
    unit_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    unit = get_unit_by_id(db, current_user.society_id, unit_id)
    if not unit:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Unit not found")
    return unit


@router.patch("/{unit_id}", response_model=UnitResponse)
def update_single_unit(
    unit_id: uuid.UUID,
    data: UnitUpdate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    unit = get_unit_by_id(db, current_user.society_id, unit_id)
    if not unit:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Unit not found")
    return update_unit(db, unit, data)


@router.delete("/{unit_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_single_unit(
    unit_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_admin)],
):
    unit = get_unit_by_id(db, current_user.society_id, unit_id)
    if not unit:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Unit not found")
    try:
        delete_unit(db, unit)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
