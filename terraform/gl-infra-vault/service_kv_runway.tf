// Runway secrets
resource "vault_mount" "runway" {
  path        = local.runway_mount_path
  type        = "kv"
  description = "Runway secrets"

  // kv-v2
  options = {
    version = 2
  }

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}
