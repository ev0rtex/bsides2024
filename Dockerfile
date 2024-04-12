ARG VAULT_VERSION=latest

FROM hashicorp/vault:${VAULT_VERSION}

RUN apk add --no-cache \
    curl \
    jq \
    postgresql-client

COPY ./vault/scripts/* /vault/scripts/
