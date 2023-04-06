FROM gitea/gitea:1.19.0

COPY entrypoint.sh /entrypoint.sh
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache inotify-tools && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]