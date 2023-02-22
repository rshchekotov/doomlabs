FROM certbot/dns-cloudflare:v1.24.0

COPY cloudflare.ini entrypoint.sh /
RUN chmod +x /entrypoint.sh && \
    chmod 600 /cloudflare.ini && \
    apk add --no-cache bash

ENTRYPOINT ["/entrypoint.sh"]