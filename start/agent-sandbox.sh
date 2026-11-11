#!/bin/sh
# Start script for the Agent-Sandbox service (image langgenius/dify-agent-local-sandbox): shells for Dify Agents.
# Starts as root (RAILWAY_RUN_UID=0) only to hand the Railway volume to the image's dify user.
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
export HOME=/home/dify
def HTTPS_PROXY "$HTTP_PROXY"
if [ "$(id -u)" = 0 ]; then
  chown -R dify:dify /home/dify
  exec setpriv --reuid=dify --regid=dify --init-groups shellctl serve --listen 0.0.0.0:5004 --require-auth-token
fi
exec shellctl serve --listen 0.0.0.0:5004 --require-auth-token
