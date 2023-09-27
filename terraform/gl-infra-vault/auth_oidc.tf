resource "vault_jwt_auth_backend" "okta" {
  path        = "oidc"
  type        = "oidc"
  description = "Okta"

  oidc_discovery_url = var.okta_oidc.discovery_url
  oidc_client_id     = var.okta_oidc.client_id
  oidc_client_secret = var.okta_oidc.client_secret

  // vault_jwt_auth_backend_role.user.role_name
  default_role = "user"

  tune {
    listing_visibility = "unauth"
    default_lease_ttl  = "24h"  // 1 day
    max_lease_ttl      = "168h" // 1 week
    token_type         = "default-service"
  }
}
