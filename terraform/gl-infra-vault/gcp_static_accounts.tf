resource "vault_gcp_secret_static_account" "account" {
  for_each = local.gcp_static_accounts

  backend = vault_gcp_secret_backend.gcp.path

  static_account        = each.value.name
  service_account_email = format(local.gcp_service_account_email_format, each.value.service_account_id, each.value.project_id)

  secret_type  = each.value.type
  token_scopes = each.value.oauth_scopes

  dynamic "binding" {
    for_each = { for binding in each.value.additional_bindings : binding.resource => binding }

    content {
      resource = binding.value.resource
      roles    = binding.value.roles
    }
  }
}
