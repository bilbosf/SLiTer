resource "vault_jwt_auth_backend" "jwt" {
  for_each = var.jwt_auth_backends

  path        = each.key
  type        = "jwt"
  description = each.value.description

  jwks_url     = each.value.jwks_url
  bound_issuer = each.value.bound_issuer

  tune {
    listing_visibility = "hidden"
    default_lease_ttl  = each.value.default_lease_ttl
    max_lease_ttl      = each.value.max_lease_ttl
    // https://www.vaultproject.io/docs/concepts/tokens
    token_type = "default-service"
  }
}
