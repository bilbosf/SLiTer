resource "vault_gcp_secret_roleset" "roleset" {
  for_each = local.gcp_rolesets

  backend = vault_gcp_secret_backend.gcp.path

  roleset = each.value.name
  project = each.value.project_id

  secret_type  = each.value.type
  token_scopes = each.value.oauth_scopes

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${each.value.project_id}"
    roles    = each.value.roles
  }

  dynamic "binding" {
    for_each = { for binding in each.value.additional_bindings : binding.resource => binding }

    content {
      resource = binding.value.resource
      roles    = binding.value.roles
    }
  }
}
