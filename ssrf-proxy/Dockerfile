# Dify SSRF proxy for Railway: upstream squid config from langgenius/dify 1.19.0 (docker/ssrf_proxy), unchanged.
# Same image as upstream's ubuntu/squid:latest, pinned by digest.
FROM ubuntu/squid:6.6-24.04_beta@sha256:6a097f68bae708cedbabd6188d68c7e2e7a38cedd05a176e1cc0ba29e3bbe029
ENV HTTP_PORT=3128 \
    COREDUMP_DIR=/var/spool/squid \
    SSRF_PROXY_ALLOW_PRIVATE_IPS= \
    SSRF_PROXY_ALLOW_PRIVATE_DOMAINS=
COPY squid.conf.template /etc/squid/squid.conf.template
COPY squid-common.conf.template /etc/squid/dify_common.conf.template
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
EXPOSE 3128
ENTRYPOINT ["/docker-entrypoint.sh"]
