#!/bin/sh

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
if ! { vault secrets list -format=json | jq -e '.["database/"]' >/dev/null 2>&1; }; then
    vault secrets enable database
fi

# Fetch the DB username and password (provided via compose secrets mount)
export PGHOST="postgresql"
export PGUSER="postgres"
export PGPASSWORD="$(cat /run/secrets/bsides_db_pass)"
export PGDATABASE="bsides"

exec "$@"
