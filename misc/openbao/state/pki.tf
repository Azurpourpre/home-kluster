# ------
# Configure pki secret engine
# ------

resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "Home-Kluster internal pki"

  default_lease_ttl_seconds = 60*60 # 1h
  max_lease_ttl_seconds = 10 * 365 * 24 * 60 * 60 # 10 yrs
}

resource "vault_pki_secret_backend_root_cert" "rootCA" {
    depends_on = [vault_mount.pki]
    backend = vault_mount.pki.path
    type = "internal"
    common_name = "hk.home"
    ttl = "${vault_mount.pki.max_lease_ttl_seconds}s"
}

resource "vault_pki_secret_backend_config_urls" "example" {
    depends_on = [vault_mount.pki, vault_pki_secret_backend_root_cert.rootCA]
    backend = vault_mount.pki.path
    issuing_certificates = ["https://vault.hk.home/v1/pki/ca"]
    crl_distribution_points=["https://vault.hk.home/v1/pki/crl"]
}