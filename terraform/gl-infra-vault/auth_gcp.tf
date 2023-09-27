resource "vault_auth_backend" "gcp" {
  path = "gcp"
  type = "gcp"

  tune {
    default_lease_ttl  = "3600s"
    max_lease_ttl      = "3600s"
    listing_visibility = "hidden"
  }
}
