#!/bin/sh
# Start script for the SSRF-Proxy service (image ubuntu/squid) with Dify's upstream squid config.
export HTTP_PORT="${HTTP_PORT:-3128}" COREDUMP_DIR="${COREDUMP_DIR:-/var/spool/squid}"
exec /dify-ssrf-entrypoint.sh
