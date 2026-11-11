# Public entry point for Dify on Railway: routes one domain to the Web, API and Plugin Daemon services
# over Railway's private network (same routes as upstream docker/nginx/conf.d/default.conf.template, 1.19.0).
FROM nginx:1.30.6-alpine@sha256:583b7f2fce1cdb8da5ad5c39ebd3c33b98b87d493190e548bdee1fa8c619c311
# Railway reports the host's CPU count, so cap worker processes (override with NGINX_WORKER_PROCESSES).
RUN rm -f /etc/nginx/conf.d/default.conf \
    && sed -i 's/^worker_processes.*/worker_processes 2;/' /etc/nginx/nginx.conf
COPY 15-railway-env.envsh /docker-entrypoint.d/15-railway-env.envsh
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY proxy.conf /etc/nginx/dify_proxy.conf
RUN chmod +x /docker-entrypoint.d/15-railway-env.envsh
