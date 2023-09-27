resource "vault_mount" "kv" {
  for_each = var.vault_kv_mounts

  path        = each.key
  type        = "kv"
  description = lookup(each.value, "description", "")

  options = {
    version = lookup(each.value, "version", "2")
  }

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}
