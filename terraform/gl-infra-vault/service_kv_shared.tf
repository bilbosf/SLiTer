// Shared secrets
resource "vault_mount" "shared" {
  path        = local.shared_mount_path
  type        = "kv"
  description = "Shared secrets"

  // kv-v2
  options = {
    version = 2
  }

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}
