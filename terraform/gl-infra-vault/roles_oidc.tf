// Admin
resource "vault_jwt_auth_backend_role" "admin" {
  backend = vault_jwt_auth_backend.okta.path

  role_name = "admin"
  role_type = "oidc"

  user_claim   = "email"
  groups_claim = "groups"
  oidc_scopes  = ["openid", "profile", "email", "groups"]

  allowed_redirect_uris = local.oidc_allowed_redirect_uris

  bound_claims = {
    groups = join(",", var.admin_groups)
  }

  verbose_oidc_logging = var.admin_oidc_logging

  // Short TTL so that the admin role is not used longer than necessary, normal use
  // should be with the default user role
  token_ttl     = 3600 // 1 hour
  token_max_ttl = 3600 // 1 hour
  token_policies = [
    vault_policy.admin.name,
    vault_policy.ci_admin_all.name,
    vault_policy.k8s_admin_all.name
  ]
}

// Users - default
resource "vault_jwt_auth_backend_role" "user" {
  backend = vault_jwt_auth_backend.okta.path

  role_name = "user"
  role_type = "oidc"

  user_claim   = "email"
  groups_claim = "groups"
  oidc_scopes  = ["openid", "profile", "email", "groups"]

  allowed_redirect_uris = local.oidc_allowed_redirect_uris

  bound_claims = {
    groups = join(",", var.user_groups)
  }

  verbose_oidc_logging = var.user_oidc_logging

  token_ttl      = 86400  // 1 day
  token_max_ttl  = 604800 // 1 week
  token_policies = []
}
