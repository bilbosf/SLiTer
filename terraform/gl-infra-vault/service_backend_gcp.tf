# GCP backend
resource "vault_gcp_secret_backend" "gcp" {
  path        = local.gcp_secrets_path
  description = "GCP OAuth tokens and Service Accounts keys"

  credentials               = var.gcp.credentials
  default_lease_ttl_seconds = var.gcp.default_lease_ttl
  max_lease_ttl_seconds     = var.gcp.max_lease_ttl

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}
