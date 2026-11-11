#!/bin/sh
# Start script for the Agent-Backend service (image langgenius/dify-agent-backend).
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
def DIFY_AGENT_RUNTIME_BACKEND local
def DIFY_AGENT_STUB_API_BASE_URL "http://${RAILWAY_PRIVATE_DOMAIN}:5050/agent-stub"
exec uvicorn dify_agent.server.app:app --host 0.0.0.0 --port 5050
