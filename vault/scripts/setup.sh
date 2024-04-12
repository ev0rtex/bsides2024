#!/bin/sh

echo "Configuring for DB: ${PGDATABASE}"

# Configure Vault with PostgreSQL
vault write database/config/${PGDATABASE} \
    plugin_name=postgresql-database-plugin \
    allowed_roles="bsides-role" \
    connection_url="postgresql://{{username}}:{{password}}@postgresql:5432/${PGDATABASE}?sslmode=disable" \
    username="${PGUSER}" \
    password="${PGPASSWORD}"

# Create a role that maps a name in Vault to an SQL statement to execute to create the database credential.
vault write database/roles/bsides-role \
    db_name="${PGDATABASE}" \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
