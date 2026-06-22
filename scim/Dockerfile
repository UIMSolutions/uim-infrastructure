FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV SCIM_BASE_URL=http://localhost:8080/scim/v2

EXPOSE 8080

CMD ["./uim-scim-service"]
