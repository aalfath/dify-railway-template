#!/bin/sh
# Prints the Railway start command for each service of the Dify template.
# Every service runs a pinned upstream image; its start command writes this repo's
# start script (and config files) into the container and runs it, so nothing is built.
# Re-run after changing a file and paste the new command into that service's settings.
set -eu
cd "$(dirname "$0")/.."
b64() { gzip -9n < "$1" | base64 -w0; }
pack() { # pack <dest-path>=<repo-file> ... -> base64 tar.gz of the files only
  tmp=$(mktemp -d)
  for pair in "$@"; do
    dest=${pair%%=*}; src=${pair#*=}
    mkdir -p "$tmp$(dirname "$dest")"; cp "$src" "$tmp$dest"
  done
  (cd "$tmp" && find . -type f | sort | tar --owner=0 --group=0 --numeric-owner --no-recursion -cf - -T -) | gzip -9n | base64 -w0
  rm -rf "$tmp"
}
script() { # script <shell> <file> [args] [prefix] -> command that unpacks and runs a start script
  printf '%s/bin/sh -c "echo %s | base64 -d | gunzip > /tmp/start.sh && exec %s /tmp/start.sh%s"' "${4:-}" "$(b64 "$2")" "$1" "${3:+ $3}"
}
line() { printf '\n# %s\n%s\n' "$1" "$2"; }

line "API (langgenius/dify-api)"    "$(script /bin/bash start/dify-api.sh api)"
line "Worker (langgenius/dify-api)" "$(script /bin/bash start/dify-api.sh worker)"
line "Beat (langgenius/dify-api)"   "$(script /bin/bash start/dify-api.sh beat)"
line "Web (langgenius/dify-web)"    "$(script /bin/sh start/web.sh)"
line "Sandbox (langgenius/dify-sandbox)" "$(script /bin/sh start/sandbox.sh)"
line "Plugin-Daemon (langgenius/dify-plugin-daemon)" "$(script /bin/bash start/plugin-daemon.sh '' '/usr/bin/tini -g -- ')"
line "Agent-Backend (langgenius/dify-agent-backend)" "$(script /bin/sh start/agent-backend.sh)"
line "Agent-Sandbox (langgenius/dify-agent-local-sandbox)" "$(script /bin/sh start/agent-sandbox.sh '' '/usr/bin/tini -g -- ')"

PROXY=$(pack \
  /docker-entrypoint.d/15-railway-env.envsh=proxy/15-railway-env.envsh \
  /etc/nginx/templates/default.conf.template=proxy/default.conf.template \
  /etc/nginx/dify_proxy.conf=proxy/proxy.conf)
line "Dify (nginx)" "/bin/sh -c \"rm -f /etc/nginx/conf.d/default.conf && sed -i 's/^worker_processes.*/worker_processes 2;/' /etc/nginx/nginx.conf && echo $PROXY | base64 -d | tar -xzf - -C / && chmod 755 /docker-entrypoint.d/15-railway-env.envsh && exec /docker-entrypoint.sh nginx -g 'daemon off;'\""

SSRF=$(pack \
  /etc/squid/squid.conf.template=ssrf-proxy/squid.conf.template \
  /etc/squid/dify_common.conf.template=ssrf-proxy/squid-common.conf.template \
  /dify-ssrf-entrypoint.sh=ssrf-proxy/dify-ssrf-entrypoint.sh \
  /dify-ssrf-start.sh=start/ssrf-proxy.sh)
line "SSRF-Proxy (ubuntu/squid)" "/bin/sh -c \"echo $SSRF | base64 -d | tar -xzf - -C / && chmod 755 /dify-ssrf-entrypoint.sh /dify-ssrf-start.sh && exec /dify-ssrf-start.sh\""
