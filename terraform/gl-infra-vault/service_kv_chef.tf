// Chef secrets
resource "vault_mount" "chef" {
  path        = local.chef_mount_path
  type        = "kv"
  description = "Chef secrets"

  // kv-v2
  options = {
    version = 2
  }

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}

// Secret placeholder file, allows users to see the KV paths
resource "vault_kv_secret_v2" "chef-env-shared-placeholder" {
  for_each = var.chef_environments

  mount = vault_mount.chef.path
  name  = "env/${each.key}/shared/${local.kv_placeholder_file}"

  data_json           = "{}"
  delete_all_versions = true

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}

// Secret placeholder file, allows users to see the KV paths
resource "vault_kv_secret_v2" "chef-cookbook-placeholder" {
  for_each = local.chef_env_cookbooks

  mount = vault_mount.chef.path
  name  = "env/${each.value.env}/cookbook/${each.value.cookbook}/${local.kv_placeholder_file}"

  data_json           = "{}"
  delete_all_versions = true

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}
