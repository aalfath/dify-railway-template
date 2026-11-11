# Dify on Railway: template wrapper

Small helper images for the Dify Railway template (Dify 1.19.0). The Dify services themselves run the
official `langgenius/*` images; this repo only holds what Railway can't express with an image alone.

| Folder | Railway service | What it does |
|---|---|---|
| `proxy/` | `Dify` (public) | nginx (pinned by digest) that serves the one public domain and routes `/console/api`, `/api`, `/v1`, `/files`, `/mcp`, `/triggers`, `/openapi`, `/socket.io` to API, `/e/` to Plugin Daemon and everything else to Web, over Railway's private network. Same routes as upstream `docker/nginx/conf.d/default.conf.template`. Health check: `/proxy-health`. |
| `ssrf-proxy/` | `SSRF Proxy` | squid with Dify's upstream SSRF config (`docker/ssrf_proxy`, unchanged): outbound HTTP from API, Worker and Sandbox goes through it, and requests to private networks are refused. |

Proxy settings (environment variables): `PORT` (default 8080), `API_HOST`/`API_PORT`, `WEB_HOST`/`WEB_PORT`,
`PLUGIN_DAEMON_HOST`/`PLUGIN_DAEMON_PORT`, `NGINX_CLIENT_MAX_BODY_SIZE` (100M), `NGINX_PROXY_TIMEOUT` (3600s).

The files in `ssrf-proxy/` are copied from [langgenius/dify](https://github.com/langgenius/dify) and are
covered by Dify's license.
