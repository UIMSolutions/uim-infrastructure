FROM docker.io/hashicorp/terraform:1.9.8 AS terraform-cli

FROM docker.io/dlanguage/dmd:2.111.0

WORKDIR /app
COPY . .

COPY --from=terraform-cli /bin/terraform /usr/local/bin/terraform

RUN dub build --build=release

ENV PORT=8080
ENV BIND_ADDRESS=0.0.0.0
ENV TERRAFORM_BINARY=terraform
ENV TERRAFORM_DEFAULT_MODULE_PATH=/app/modules/example
ENV TERRAFORM_AUTO_APPROVE=true

EXPOSE 8080

CMD ["./uim-terraform-service"]