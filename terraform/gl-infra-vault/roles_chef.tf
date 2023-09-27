resource "vault_gcp_auth_backend_role" "gce-chef" {
  for_each = local.chef_environment_roles
  backend  = vault_auth_backend.gcp.path

  role = each.value.role_name
  type = "gce"

  bound_projects        = each.value.gcp_projects
  bound_instance_groups = each.value.gcp_instance_groups
  bound_zones           = each.value.gcp_zones
  bound_labels          = each.value.gcp_labels

  token_policies = [
    vault_policy.chef_role[each.key].name
  ]
}
