# This file exists solely for Alembic autogenerate — it imports Base and all
# models so Alembic can detect schema changes. Application code should import
# Base from app.db.base_class, not here.
from app.db.base_class import Base  # noqa: F401
from app.models.society import Society  # noqa: F401
from app.models.user import User  # noqa: F401
from app.models.complaint import Complaint  # noqa: F401
