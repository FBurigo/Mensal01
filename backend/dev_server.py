"""
Servidor de desenvolvimento local — sem Docker, sem MySQL.
Usa SQLite em arquivo e serve o frontend a partir da mesma porta (8000).

Como rodar:
    cd backend
    pip install -r requirements.txt aiofiles
    set DATABASE_URL=sqlite+pysqlite:///./biblioteca_dev.db
    alembic upgrade head
    uvicorn dev_server:app --reload --port 8000
"""
import os
import pathlib

# Define SQLite antes de qualquer import da app
os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite:///./biblioteca_dev.db")

from app.main import app  # noqa: E402
from fastapi.staticfiles import StaticFiles  # noqa: E402

# Pasta do frontend: backend/../frontend/src
_frontend_dir = pathlib.Path(__file__).parent.parent / "frontend" / "src"

# Monta os arquivos estáticos em "/" — as rotas /api/* do FastAPI têm prioridade
app.mount("/", StaticFiles(directory=str(_frontend_dir), html=True), name="frontend")
