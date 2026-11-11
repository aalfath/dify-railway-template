#!/bin/sh
# Start script for the Sandbox service (image langgenius/dify-sandbox): runs Python and JavaScript code nodes.
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
def SANDBOX_PORT 8194
def GIN_MODE release
def WORKER_TIMEOUT 15
def ENABLE_NETWORK true
def HTTPS_PROXY "$HTTP_PROXY"
exec /entrypoint.sh
