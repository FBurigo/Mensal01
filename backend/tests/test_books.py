import os

os.environ["DATABASE_URL"] = "sqlite+pysqlite:///:memory:"

from app.database import get_db
from app.main import app
from app.models import Base
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

engine = create_engine(
    "sqlite+pysqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSession = sessionmaker(bind=engine, expire_on_commit=False)
Base.metadata.create_all(engine)


def override_get_db():
    with TestingSession() as session:
        yield session


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def setup_function() -> None:
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)


def sample_book(**overrides):
    payload = {
        "title": "Clean Code",
        "author": "Robert C. Martin",
        "isbn": "9780132350884",
        "category": "Tecnologia",
        "reading_status": "QUERO_LER",
        "rating": None,
        "notes": "Leitura do semestre",
    }
    payload.update(overrides)
    return payload


def test_version_endpoint_returns_app_version() -> None:
    response = client.get("/api/version")
    assert response.status_code == 200
    assert response.json() == {"version": os.environ.get("APP_VERSION", "dev")}


def test_complete_book_lifecycle() -> None:
    created = client.post("/api/books", json=sample_book())
    assert created.status_code == 201
    book_id = created.json()["id"]
    assert created.headers["location"] == f"/api/books/{book_id}"

    listed = client.get("/api/books", params={"q": "clean"})
    assert listed.status_code == 200
    assert len(listed.json()) == 1

    replaced = client.put(
        f"/api/books/{book_id}",
        json=sample_book(title="Código Limpo", rating=5),
    )
    assert replaced.status_code == 200
    assert replaced.json()["rating"] == 5

    patched = client.patch(
        f"/api/books/{book_id}/status", json={"reading_status": "LIDO"}
    )
    assert patched.status_code == 200
    assert patched.json()["reading_status"] == "LIDO"

    deleted = client.delete(f"/api/books/{book_id}")
    assert deleted.status_code == 204
    assert client.get(f"/api/books/{book_id}").status_code == 404


def test_rejects_duplicate_isbn() -> None:
    assert client.post("/api/books", json=sample_book()).status_code == 201
    duplicate = client.post("/api/books", json=sample_book(title="Outro livro"))
    assert duplicate.status_code == 409


def test_validates_rating() -> None:
    response = client.post("/api/books", json=sample_book(rating=6))
    assert response.status_code == 422


def test_health_checks_database() -> None:
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "database": "connected"}
