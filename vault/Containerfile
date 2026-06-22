FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV VAULT_SERVER_NAME=uim-vault-service
ENV VAULT_SERVER_VERSION=0.1.0
ENV VAULT_DEFAULT_TTL_SECONDS=3600

EXPOSE 8080

CMD ["./uim-vault-service"]
