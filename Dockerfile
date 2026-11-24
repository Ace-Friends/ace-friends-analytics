FROM python:3.12-slim-bookworm AS builder

ARG POETRY_VERSION=2.3.4

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:/opt/poetry/bin:$PATH"

RUN python -m venv /opt/poetry \
    && /opt/poetry/bin/pip install --no-cache-dir "poetry==${POETRY_VERSION}" \
    && python -m venv /opt/venv

WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN poetry install --only main --no-root --no-ansi

FROM python:3.12-slim-bookworm AS production

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    ANALYTICS_HOST=0.0.0.0 \
    ANALYTICS_PORT=15700

RUN groupadd --system appgroup \
    && useradd --system --gid appgroup --home-dir /app --shell /usr/sbin/nologin appuser

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --chown=appuser:appgroup server ./server

USER appuser

EXPOSE 15700

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
    CMD ["python", "-c", "import urllib.request; from server.core.config import settings; urllib.request.urlopen(f'http://127.0.0.1:{settings.port}/ping', timeout=3).read()"]

CMD ["python", "-m", "server.main"]
