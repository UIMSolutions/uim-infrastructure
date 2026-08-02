FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV PASSWD_FILE=/data/passwd
ENV SHADOW_FILE=/data/shadow

EXPOSE 8080

CMD ["./uim-hts-service"]
