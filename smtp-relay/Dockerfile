FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV PID_FILE=/var/run/uim-smtp-relay-service.pid
ENV SMTP_HOST=mailhog
ENV SMTP_PORT=1025
ENV SMTP_FROM=noreply@uim.local

EXPOSE 8080

CMD ["./uim-smtp-relay-service"]
