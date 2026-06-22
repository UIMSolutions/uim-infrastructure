FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV MCP_SERVER_NAME=uim-mcp-service
ENV MCP_SERVER_VERSION=0.1.0

EXPOSE 8080

CMD ["./uim-mcp-service"]
