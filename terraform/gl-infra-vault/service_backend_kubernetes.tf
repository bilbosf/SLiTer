# Kubernetes backend
resource "vault_kubernetes_secret_backend" "cluster" {
  for_each = local.kubernetes_secrets_clusters

  path        = join("/", [local.kubernetes_mount_path_prefix, each.key])
  description = format("Service Accounts tokens for Kubernetes Cluster %s", each.key)

  kubernetes_host     = each.value.config.host
  kubernetes_ca_cert  = each.value.config.ca_cert
  service_account_jwt = each.value.config.service_account_jwt

  default_lease_ttl_seconds = 3600  # 1 hour
  max_lease_ttl_seconds     = 10800 # 3 hours

  depends_on = [
    vault_policy.admin,
    vault_policy.vault-provisioning,
  ]
}

resource "vault_kubernetes_secret_backend_role" "role" {
  for_each = local.kubernetes_secrets_roles

  backend = vault_kubernetes_secret_backend.cluster[each.value.cluster].path
  name    = each.value.name

  allowed_kubernetes_namespaces = each.value.allowed_kubernetes_namespaces
  name_template                 = each.value.name_template
  kubernetes_role_name          = each.value.role_name
  kubernetes_role_type          = each.value.role_type
  generated_role_rules = length(each.value.role_rules) > 0 ? jsonencode({
    rules = [
      for rule in each.value.role_rules :
      { for k, v in rule : k => v if v != null }
    ]
  }) : null
  service_account_name = each.value.service_account_name

  extra_annotations = each.value.extra_annotations
  extra_labels      = each.value.extra_labels

  token_default_ttl = each.value.token_default_ttl
  token_max_ttl     = each.value.token_max_ttl
}
