import uvicorn
from fastapi import FastAPI

from server.core.config import settings

app = FastAPI(
    title="ACE Friends Analytics",
    description="Каркас отдельного сервиса аналитики ACE Friends.",
    version="0.1.0",
)


@app.get("/ping", tags=["health"], summary="Проверка доступности сервиса")
async def ping() -> dict[str, str]:
    return {"status": "ok", "service": "ace-friends-analytics"}


if __name__ == "__main__":
    uvicorn.run(
        "server.main:app",
        host=settings.host,
        port=settings.port,
        log_level=settings.log_level,
        timeout_graceful_shutdown=20,
    )
