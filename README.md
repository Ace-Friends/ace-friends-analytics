# ACE Friends Analytics

Отдельный сервис аналитики ACE Friends. Начальный каркас включает FastAPI,
настройки окружения, зависимости Poetry и запуск в Docker.

## Что уже работает

- `GET /ping` — проверка доступности процесса.
- `GET /docs` — интерактивная документация Swagger.
- `GET /openapi.json` — описание HTTP API.

Пример ответа `/ping`:

```json
{"status": "ok", "service": "ace-friends-analytics"}
```

## Запуск в Docker

Нужен Docker Desktop или Docker Engine с Compose.

Из корня репозитория:

```powershell
docker compose up -d --build --wait
docker compose ps
```

Открыть [Swagger](http://127.0.0.1:15700/docs) или
[проверку доступности](http://127.0.0.1:15700/ping).

```powershell
docker compose logs --tail 50 analytics
docker compose stop
```

Команда `stop` останавливает сервис. Повторный запуск —
`docker compose up -d --wait`.

Образ собирается в два этапа. В итоговый образ попадают зависимости приложения
из lock-файла и папка `server/`. Процесс работает от отдельного пользователя.
Docker проверяет `/ping` и ограничивает размер файлов журналов.
Порт опубликован на `127.0.0.1` для локальной разработки.

## Локальная разработка

Нужны Python 3.12 и Poetry 2.3.4.

Если Poetry ещё требуется установить и доступен `uv`:

```powershell
uv tool install poetry==2.3.4
```

Зависимости устанавливаются из `poetry.lock`:

```powershell
poetry env use 3.12
poetry install
Copy-Item .env.example .env # если .env ещё отсутствует
poetry run python -m server.main
```

Для автоматического перезапуска при редактировании:

```powershell
poetry run uvicorn server.main:app --reload --host 127.0.0.1 --port 15700
```

## Настройки

| Переменная | По умолчанию | Назначение |
| --- | --- | --- |
| `ANALYTICS_HOST` | `127.0.0.1` | Адрес прослушивания при локальном запуске |
| `ANALYTICS_PORT` | `15700` | Локальный порт и опубликованный порт Compose |
| `ANALYTICS_LOG_LEVEL` | `info` | Уровень журналирования |

Локальный запуск читает `.env`. Compose использует `.env` для подстановки
порта и уровня журналирования. В контейнере приложение слушает `0.0.0.0:15700`.

## Структура

```text
server/
  main.py            Приложение FastAPI, /ping и запуск Uvicorn
  core/config.py     Настройки из окружения и .env
pyproject.toml       Зависимости и настройки инструментов
poetry.lock          Зафиксированные версии зависимостей
Dockerfile           Сборка образа приложения
compose.yaml         Локальный запуск контейнера
.env.example         Пример настроек
```

## Проверки и зависимости

```powershell
poetry check --lock
poetry run ruff check server
poetry run ruff format --check server
poetry run mypy server
```

В группе разработки также установлены pytest и HTTPX для будущих проверок API.

Добавление зависимости выполняется через `poetry add <package>`,
инструмента разработки — через `poetry add --group dev <package>`.
Изменения `pyproject.toml` и `poetry.lock` сохраняются вместе.
