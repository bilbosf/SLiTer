// Kubernetes
resource "vault_mount" "kubernetes" {
  path        = local.kubernetes_kv_mount_path
  type        = "kv"
  description = "Secrets for Kubernetes"

  // kv-v2
  options = {
    version = 2
  }

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}

// Secret placeholder file for each k8s namespace, allows users to see the KV paths
resource "vault_kv_secret_v2" "kubernetes_namespace_placeholder" {
  for_each = { for id, ns in local.kubernetes_kv_namespaces : id => ns if length(regexall("\\*", ns.namespace)) == 0 }

  mount = vault_mount.kubernetes.path
  name  = "${each.value.cluster}/${each.value.namespace}/${local.kv_placeholder_file}"

  data_json           = "{}"
  delete_all_versions = true

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}

// Secret placeholder file for each k8s environment, allows users to see the KV paths
resource "vault_kv_secret_v2" "kubernetes_env_placeholder" {
  for_each = local.kubernetes_kv_environments

  mount = vault_mount.kubernetes.path
  name  = "env/${each.value}/${local.kv_placeholder_file}"

  data_json           = "{}"
  delete_all_versions = true

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}

// Secret placeholder file for each k8s environment and namespace, allows users to see the KV paths
resource "vault_kv_secret_v2" "kubernetes_env_ns_placeholder" {
  for_each = { for id, ns in local.kubernetes_kv_env_namespaces : id => ns if length(regexall("\\*", ns.namespace)) == 0 }

  mount = vault_mount.kubernetes.path
  name  = "env/${each.value.environment}/ns/${each.value.namespace}/${local.kv_placeholder_file}"

  data_json           = "{}"
  delete_all_versions = true

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}
