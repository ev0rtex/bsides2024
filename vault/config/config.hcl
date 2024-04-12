storage "file" {
  path = "/vault/data"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}
seal "awskms" {
  region     = "us-east-1"
  access_key = "nonproduction"  # Vault wants something set
  secret_key = "nonproduction"  # Vault wants something set
  kms_key_id = "alias/vault-unseal"
  endpoint   = "http://kms"
}
api_addr          = "http://127.0.0.1:8200"
default_lease_ttl = "168h"
max_lease_ttl     = "720h"
ui                = true
