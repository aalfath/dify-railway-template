#!/bin/sh
# Start script for the Web service (image langgenius/dify-web).
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
P="${DIFY_PUBLIC_URL:?DIFY_PUBLIC_URL is not set}"; P="${P%/}"
def CONSOLE_API_URL "$P"
def APP_API_URL "$P"
def CONSOLE_WEB_URL "$P"
def NEXT_PUBLIC_SOCKET_URL "$(echo "$P" | sed 's#^https://#wss://#; s#^http://#ws://#')"
export HOSTNAME=::   # listen on IPv4 and IPv6 (Docker sets HOSTNAME to the container name)
def DEPLOY_ENV PRODUCTION
def MARKETPLACE_API_URL https://marketplace.dify.ai
def MARKETPLACE_URL https://marketplace.dify.ai
def NEXT_PUBLIC_ENABLE_AGENT_V2 true
def TEXT_GENERATION_TIMEOUT_MS 60000
def LOOP_NODE_MAX_COUNT 100
def MAX_TOOLS_NUM 10
def MAX_PARALLEL_LIMIT 10
def MAX_ITERATIONS_NUM 99
def MAX_TREE_DEPTH 50
def INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH 4000
def TOP_K_MAX_VALUE 10
def ALLOW_EMBED false
def NEXT_TELEMETRY_DISABLED 1
exec /bin/sh ./entrypoint.sh
