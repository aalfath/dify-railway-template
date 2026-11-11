#!/bin/bash
# Start script for the Plugin-Daemon service (image langgenius/dify-plugin-daemon:*-local).
# Starts as root (RAILWAY_RUN_UID=0) only to hand the Railway volume to the image's dify user.
set -e
def() { if [ -z "$(printenv "$1")" ]; then export "$1=$2"; fi; }
def SERVER_PORT 5002
def DB_TYPE postgresql
def DB_DATABASE dify_plugin
def DB_SSL_MODE disable
def REDIS_PORT 6379
def PLUGIN_STORAGE_TYPE local
def PLUGIN_STORAGE_LOCAL_ROOT /app/storage
def PLUGIN_WORKING_PATH /app/storage/cwd
def PLUGIN_INSTALLED_PATH plugin
def PLUGIN_PACKAGE_CACHE_PATH plugin_packages
def PLUGIN_MEDIA_CACHE_PATH assets
def FORCE_VERIFYING_SIGNATURE true
def PYTHON_ENV_INIT_TIMEOUT 120
def PLUGIN_MAX_EXECUTION_TIMEOUT 600
def MAX_PLUGIN_PACKAGE_SIZE 52428800
def PLUGIN_REMOTE_INSTALLING_HOST 0.0.0.0
def PLUGIN_REMOTE_INSTALLING_PORT 5003
def PPROF_ENABLED false
export HOME=/home/dify
if [ "$(id -u)" = 0 ]; then
  chown -R dify:dify /app/storage
  # A stale database address can hang the migration; time out so Railway restarts the service.
  exec setpriv --reuid=dify --regid=dify --init-groups bash -c 'timeout 120 /app/commandline migrate && exec /app/main'
fi
timeout 120 /app/commandline migrate
exec /app/main
