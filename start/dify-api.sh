#!/bin/bash
# Start script for the API, Worker and Beat services (image langgenius/dify-api).
# Usage: dify-api.sh api|worker|beat
# Fixed settings get a default here; any variable set on the Railway service wins.
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
export MODE="$1"

def LOG_LEVEL INFO
def DB_TYPE postgresql
def REDIS_PORT 6379
def CELERY_BROKER_URL "redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/1"

if [ "$MODE" = beat ]; then
  # Beat only schedules tasks; it needs the database and Redis, not file storage.
  def MIGRATION_ENABLED false
  exec /bin/bash /entrypoint.sh
fi

# One public domain for console, apps, API and files (served by the Dify proxy service).
# Always derived from DIFY_PUBLIC_URL: the image bakes in http://127.0.0.1 defaults for some of these.
P="${DIFY_PUBLIC_URL:?DIFY_PUBLIC_URL is not set}"; P="${P%/}"
for v in CONSOLE_WEB_URL CONSOLE_API_URL SERVICE_API_URL APP_WEB_URL APP_API_URL FILES_URL TRIGGER_URL; do export "$v=$P"; done
def ENDPOINT_URL_TEMPLATE "$P/e/{hook_id}"
def RESPECT_XFORWARD_HEADERS_ENABLED true

# Uploaded files: the Railway bucket (S3 API, virtual-hosted addressing).
def STORAGE_TYPE s3
def S3_ADDRESS_STYLE virtual
def S3_USE_AWS_MANAGED_IAM false

# Knowledge embeddings: pgvector in the same Postgres.
def VECTOR_STORE pgvector
def PGVECTOR_HOST "$DB_HOST"
def PGVECTOR_PORT "${DB_PORT:-5432}"
def PGVECTOR_USER "$DB_USERNAME"
def PGVECTOR_PASSWORD "$DB_PASSWORD"
def PGVECTOR_DATABASE "$DB_DATABASE"

def SSRF_PROXY_HTTPS_URL "$SSRF_PROXY_HTTP_URL"
def PLUGIN_MAX_PACKAGE_SIZE 52428800
def PLUGIN_DAEMON_TIMEOUT 600.0
def NEXT_PUBLIC_ENABLE_AGENT_V2 true

if [ "$MODE" = api ]; then
  def MIGRATION_ENABLED true
  def SERVER_WORKER_CLASS geventwebsocket.gunicorn.workers.GeventWebSocketWorker
  def GUNICORN_TIMEOUT 360
else
  def MIGRATION_ENABLED false
  def CELERY_WORKER_AMOUNT 4
fi
exec /bin/bash /entrypoint.sh
