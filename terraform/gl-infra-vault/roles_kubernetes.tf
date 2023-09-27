resource "vault_kubernetes_auth_backend_role" "role" {
  for_each = local.kubernetes_kv_roles

  backend   = vault_auth_backend.kubernetes[each.value.cluster].path
  role_name = each.value.role_name

  bound_service_account_names      = each.value.service_accounts
  bound_service_account_namespaces = each.value.namespaces

  token_ttl     = 3600 // 1 hour
  token_max_ttl = 7200 // 2 hours

  token_policies = setunion(
    each.value.policies,
    [format(local.k8s_role_policy_format, each.value.cluster, each.value.role_name)],
  )
}
