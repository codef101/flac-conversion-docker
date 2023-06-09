FROM alpine:latest

RUN apk --no-cache add ffmpeg inotify-tools

WORKDIR /app

VOLUME ["/app/input", "/app/output", "/app/failed"]

COPY script.sh /app/script.sh
RUN chmod +x /app/script.sh

ENTRYPOINT ["/bin/sh", "/app/script.sh"]
