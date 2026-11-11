#!/bin/sh
# Prints the Railway start commands for the "Dify" (proxy) and "SSRF-Proxy" services.
# Each command unpacks this repo's config files into the pinned upstream image, then starts it,
# so the template needs no build step. Re-run after changing a file and paste the output into
# the service's start command.
set -eu
cd "$(dirname "$0")/.."
pack() { # pack <dest-path>=<repo-file> ...
  tmp=$(mktemp -d)
  for pair in "$@"; do
    dest=${pair%%=*}; src=${pair#*=}
    mkdir -p "$tmp$(dirname "$dest")"; cp "$src" "$tmp$dest"
  done
  chmod 755 "$tmp"/docker-entrypoint.d/*.envsh "$tmp"/dify-ssrf-entrypoint.sh 2>/dev/null || true
  # Archive the files only (no directory entries), so extracting into / never changes existing directory modes.
  (cd "$tmp" && find . -type f | sort | tar --owner=0 --group=0 --numeric-owner --no-recursion -cf - -T -) | gzip -9n | base64 -w0
  rm -rf "$tmp"
}
PROXY=$(pack \
  /docker-entrypoint.d/15-railway-env.envsh=proxy/15-railway-env.envsh \
  /etc/nginx/templates/default.conf.template=proxy/default.conf.template \
  /etc/nginx/dify_proxy.conf=proxy/proxy.conf)
SSRF=$(pack \
  /etc/squid/squid.conf.template=ssrf-proxy/squid.conf.template \
  /etc/squid/dify_common.conf.template=ssrf-proxy/squid-common.conf.template \
  /dify-ssrf-entrypoint.sh=ssrf-proxy/dify-ssrf-entrypoint.sh)
echo "# Dify (image nginx:1.30.6-alpine@sha256:583b7f2fce1cdb8da5ad5c39ebd3c33b98b87d493190e548bdee1fa8c619c311)"
echo "/bin/sh -c \"rm -f /etc/nginx/conf.d/default.conf && sed -i 's/^worker_processes.*/worker_processes 2;/' /etc/nginx/nginx.conf && echo $PROXY | base64 -d | tar -xzf - -C / && exec /docker-entrypoint.sh nginx -g 'daemon off;'\""
echo "# SSRF-Proxy (image ubuntu/squid:6.6-24.04_beta@sha256:6a097f68bae708cedbabd6188d68c7e2e7a38cedd05a176e1cc0ba29e3bbe029)"
echo "/bin/sh -c \"echo $SSRF | base64 -d | tar -xzf - -C / && exec /dify-ssrf-entrypoint.sh\""
