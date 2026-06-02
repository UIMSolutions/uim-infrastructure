FROM dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=9312
ENV BIND_ADDRESS=0.0.0.0

EXPOSE 9312

CMD ["./uim-archer-service"]
