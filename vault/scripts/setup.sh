#!/bin/sh

# Make sure we have curl installed
(
     command -v curl >/dev/null 2>&1    \
  && command -v jq >/dev/null 2>&1      \
) || apk add --no-cache \
    curl \
    jq

# Wait until Vault server is up
while ! curl -sL --head "${VAULT_ADDR}" | grep "200 OK"; do
    sleep 1
done

# Run operator init
if ! test -f /vault/init/kmsinit.json; then
    echo "Initializing Vault"
    vault operator init -format=json | tee /vault/init/kmsinit.json
fi

# Login to Vault as root
vault login token="$(jq -r .root_token /vault/init/kmsinit.json)"

# Enable database secrets engine
vault secrets enable database

# Fetch the DB username and password (provided via compose secrets mount)
DB_NAME="bsides"
DB_USER="bsides"
DB_PASS="$(cat /run/secrets/bsides_db_pass)"

# Configure Vault with PostgreSQL
vault write database/config/${DB_NAME} \
    plugin_name=postgresql-database-plugin \
    allowed_roles="bsides-role" \
    connection_url="postgresql://{{username}}:{{password}}@postgresql:5432/${DB_NAME}?sslmode=disable" \
    username="${DB_USER}" \
    password="${DB_PASS}"

# Create a role that maps a name in Vault to an SQL statement to execute to create the database credential.
vault write database/roles/bsides-role \
    db_name=${DB_NAME} \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
