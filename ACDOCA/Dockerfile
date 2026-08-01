FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV PID_FILE=/var/run/uim-acdoca-service.pid
ENV ACDOCA_DEFAULT_COMPANY_CODE=1000

EXPOSE 8080

CMD ["./uim-acdoca-service"]
