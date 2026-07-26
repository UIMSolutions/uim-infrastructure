FROM dlanguage/dmd:2.111.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=9321
ENV BIND_ADDRESS=0.0.0.0

EXPOSE 9321

CMD ["./uim-ca-service"]
