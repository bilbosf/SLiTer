resource "vault_auth_backend" "approle" {
  path = "approle"
  type = "approle"

  tune {
    default_lease_ttl  = "3600s"
    max_lease_ttl      = "3600s"
    listing_visibility = "hidden"
  }
}
