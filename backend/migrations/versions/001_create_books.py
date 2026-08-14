"""Cria a tabela de livros.

Revision ID: 001
Revises:
"""

import sqlalchemy as sa
from alembic import op

revision = "001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "books",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("title", sa.String(length=160), nullable=False),
        sa.Column("author", sa.String(length=120), nullable=False),
        sa.Column("isbn", sa.String(length=20), nullable=True),
        sa.Column("category", sa.String(length=80), nullable=False),
        sa.Column("reading_status", sa.String(length=20), nullable=False),
        sa.Column("rating", sa.Integer(), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.CheckConstraint(
            "reading_status IN ('QUERO_LER', 'LENDO', 'LIDO')",
            name="ck_books_reading_status",
        ),
        sa.CheckConstraint(
            "rating IS NULL OR (rating >= 1 AND rating <= 5)",
            name="ck_books_rating",
        ),
        sa.UniqueConstraint("isbn", name="uq_books_isbn"),
    )
    op.create_index("ix_books_title", "books", ["title"])
    op.create_index("ix_books_author", "books", ["author"])
    op.create_index("ix_books_reading_status", "books", ["reading_status"])


def downgrade() -> None:
    op.drop_index("ix_books_reading_status", table_name="books")
    op.drop_index("ix_books_author", table_name="books")
    op.drop_index("ix_books_title", table_name="books")
    op.drop_table("books")
