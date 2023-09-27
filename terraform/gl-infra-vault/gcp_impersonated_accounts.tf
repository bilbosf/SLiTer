resource "vault_gcp_secret_impersonated_account" "account" {
  for_each = local.gcp_impersonated_accounts

  backend = vault_gcp_secret_backend.gcp.path

  impersonated_account  = each.value.name
  service_account_email = format(local.gcp_service_account_email_format, each.value.service_account_id, each.value.project_id)

  token_scopes = each.value.oauth_scopes
}
