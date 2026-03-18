"""add_invite_fields_to_users

Revision ID: 5d8e2a1f7c03
Revises: 3c7a1f9e0b44
Create Date: 2026-03-18

Adds invite_token, invite_expires_at, and is_activated columns to users table.
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = "5d8e2a1f7c03"
down_revision = "3c7a1f9e0b44"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("is_activated", sa.Boolean(), nullable=False, server_default="true"))
    op.add_column("users", sa.Column("invite_token", sa.String(32), nullable=True))
    op.add_column("users", sa.Column("invite_expires_at", sa.DateTime(timezone=True), nullable=True))
    op.create_index("ix_users_invite_token", "users", ["invite_token"], unique=True)


def downgrade() -> None:
    op.drop_index("ix_users_invite_token", table_name="users")
    op.drop_column("users", "invite_expires_at")
    op.drop_column("users", "invite_token")
    op.drop_column("users", "is_activated")
