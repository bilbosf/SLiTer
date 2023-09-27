// GitLab CI
resource "vault_mount" "ci" {
  path        = local.ci_mount_path
  type        = "kv"
  description = "Secrets for GitLab CI"

  // kv-v2
  options = {
    version = 2
  }

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}

// Transit secrets engine
resource "vault_mount" "transit-ci" {
  path        = local.ci_transit_mount_path
  type        = "transit"
  description = "Transit secrets engine for GitLab CI"
}
