# ------
# Configure cert-manager access to pki
# ------

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "cert-manager"
  ttl              = 60 * 60 # 1h
  allowed_domains  = ["hk.home"]
  allow_subdomains = true
}

resource "vault_policy" "cert_manager" {
  name = "cert-manager"

  policy = <<EOF
path "pki/issue/cert-manager" {
  capabilities = ["create", "update"]
}

path "pki/sign/cert-manager" {
  capabilities = ["create", "update"]
}
EOF
}

resource "vault_kubernetes_auth_backend_role" "example" {
  backend = vault_auth_backend.kubernetes.path
  role_name = "cert-manager"
  bound_service_account_names = ["issuer"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl = 3600
  token_policies = [ vault_policy.cert_manager.name ]
}

