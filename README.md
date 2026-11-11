# Dify on Railway: template helpers

Start scripts and config for the Dify Railway template (Dify 1.19.0). Every service in the template runs
a pinned upstream image; nothing is built. Each service's start command writes its script from this repo
into the container and runs it (`scripts/start-commands.sh` prints them).

The `start/` scripts give Dify's fixed settings a default (the same values as upstream
`docker/envs/*.defaults`), so the template only needs variables for secrets, ports and service links.
Any variable you set on a Railway service overrides the script's default.

| Folder | Railway service | Image | What it does |
|---|---|---|---|
| `proxy/` | `Dify` (public) | `nginx:1.30.6-alpine` (digest-pinned) | Serves the one public domain. Routes `/console/api`, `/api`, `/v1`, `/files`, `/mcp`, `/triggers`, `/openapi`, `/callbacks/human-input/v2/im/` and `/socket.io` to API, `/e/` to Plugin-Daemon and everything else to Web, over Railway's private network. Same routes as upstream `docker/nginx/conf.d/default.conf.template`. Health check: `/proxy-health`. |
| `ssrf-proxy/` | `SSRF-Proxy` | `ubuntu/squid` (same digest as upstream's `latest`) | Dify's upstream SSRF proxy config (`docker/ssrf_proxy`, unchanged). Outbound HTTP from API, Worker, Sandbox and Agent-Sandbox goes through it, and requests to private networks are refused. |

Proxy settings (environment variables): `PORT` (default 8080), `API_HOST`/`API_PORT`, `WEB_HOST`/`WEB_PORT`,
`PLUGIN_DAEMON_HOST`/`PLUGIN_DAEMON_PORT`, `NGINX_CLIENT_MAX_BODY_SIZE` (100M), `NGINX_PROXY_TIMEOUT` (3600s).
The SSRF proxy reads `HTTP_PORT` (3128) and `COREDUMP_DIR` (`/var/spool/squid`), plus the optional upstream
allow-lists `SSRF_PROXY_ALLOW_PRIVATE_IPS` and `SSRF_PROXY_ALLOW_PRIVATE_DOMAINS`.

## Changing a script or config file

Edit the file, run `scripts/start-commands.sh`, and paste the printed command into that service's start
command on Railway.

The files in `ssrf-proxy/` are copied from [langgenius/dify](https://github.com/langgenius/dify) and are
covered by Dify's license.
