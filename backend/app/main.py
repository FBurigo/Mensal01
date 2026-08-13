import os
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Query, Response, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import or_, select, text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Book
from app.schemas import (
    BookCreate,
    BookReplace,
    BookResponse,
    BookStatusUpdate,
    HealthResponse,
    ReadingStatus,
    VersionResponse,
)

# Identifica a versão implantada. É definida em tempo de build da imagem
# Docker (ARG/ENV APP_VERSION), a partir do SHA do commit publicado pelo
# pipeline de CI/CD. Em ambiente local sem build, cai para "dev".
APP_VERSION = os.environ.get("APP_VERSION", "dev")

app = FastAPI(
    title="Biblioteca Pessoal API",
    version="1.0.0",
    description="API REST para organizar uma biblioteca pessoal.",
    docs_url="/api/docs",
    openapi_url="/api/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://localhost:8080"],
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Content-Type"],
)

DbSession = Annotated[Session, Depends(get_db)]


def get_book_or_404(book_id: int, db: Session) -> Book:
    book = db.get(Book, book_id)
    if book is None:
        raise HTTPException(status_code=404, detail="Livro não encontrado.")
    return book


def commit_or_conflict(db: Session) -> None:
    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=409, detail="Já existe um livro com este ISBN."
        ) from exc


@app.get("/api/version", response_model=VersionResponse, tags=["Saúde"])
def version() -> VersionResponse:
    return VersionResponse(version=APP_VERSION)


@app.get("/api/health", response_model=HealthResponse, tags=["Saúde"])
def health(db: DbSession) -> HealthResponse:
    try:
        db.execute(text("SELECT 1"))
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Banco indisponível.") from exc
    return HealthResponse(status="ok", database="connected")


@app.get("/api/books", response_model=list[BookResponse], tags=["Livros"])
def list_books(
    db: DbSession,
    q: Annotated[str | None, Query(max_length=120)] = None,
    reading_status: ReadingStatus | None = None,
) -> list[Book]:
    query = select(Book)
    if q:
        pattern = f"%{q.strip()}%"
        query = query.where(
            or_(Book.title.ilike(pattern), Book.author.ilike(pattern))
        )
    if reading_status:
        query = query.where(Book.reading_status == reading_status.value)
    query = query.order_by(Book.created_at.desc(), Book.id.desc())
    return list(db.scalars(query))


@app.get("/api/books/{book_id}", response_model=BookResponse, tags=["Livros"])
def get_book(book_id: int, db: DbSession) -> Book:
    return get_book_or_404(book_id, db)


@app.post(
    "/api/books",
    response_model=BookResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Livros"],
)
def create_book(payload: BookCreate, response: Response, db: DbSession) -> Book:
    book = Book(**payload.model_dump(mode="json"))
    db.add(book)
    commit_or_conflict(db)
    db.refresh(book)
    response.headers["Location"] = f"/api/books/{book.id}"
    return book


@app.put("/api/books/{book_id}", response_model=BookResponse, tags=["Livros"])
def replace_book(book_id: int, payload: BookReplace, db: DbSession) -> Book:
    book = get_book_or_404(book_id, db)
    for field, value in payload.model_dump(mode="json").items():
        setattr(book, field, value)
    commit_or_conflict(db)
    db.refresh(book)
    return book


@app.patch(
    "/api/books/{book_id}/status", response_model=BookResponse, tags=["Livros"]
)
def update_book_status(
    book_id: int, payload: BookStatusUpdate, db: DbSession
) -> Book:
    book = get_book_or_404(book_id, db)
    book.reading_status = payload.reading_status.value
    commit_or_conflict(db)
    db.refresh(book)
    return book


@app.delete(
    "/api/books/{book_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Livros"]
)
def delete_book(book_id: int, db: DbSession) -> Response:
    book = get_book_or_404(book_id, db)
    db.delete(book)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
