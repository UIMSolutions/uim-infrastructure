FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV AI_PROVIDER=sap-ai-core
ENV DEFAULT_TENANT_ID=default

EXPOSE 8080

CMD ["./uim-sdk-ai-service"]
