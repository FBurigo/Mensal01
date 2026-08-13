from datetime import datetime
from enum import StrEnum

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ReadingStatus(StrEnum):
    QUERO_LER = "QUERO_LER"
    LENDO = "LENDO"
    LIDO = "LIDO"


class BookFields(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    title: str = Field(min_length=1, max_length=160)
    author: str = Field(min_length=1, max_length=120)
    isbn: str | None = Field(default=None, max_length=20)
    category: str = Field(default="Geral", min_length=1, max_length=80)
    reading_status: ReadingStatus = ReadingStatus.QUERO_LER
    rating: int | None = Field(default=None, ge=1, le=5)
    notes: str | None = Field(default=None, max_length=2000)

    @field_validator("isbn", "notes", mode="before")
    @classmethod
    def empty_string_to_none(cls, value: object) -> object:
        if isinstance(value, str) and not value.strip():
            return None
        return value


class BookCreate(BookFields):
    pass


class BookReplace(BookFields):
    pass


class BookStatusUpdate(BaseModel):
    reading_status: ReadingStatus


class BookResponse(BookFields):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime


class HealthResponse(BaseModel):
    status: str
    database: str


class VersionResponse(BaseModel):
    version: str
