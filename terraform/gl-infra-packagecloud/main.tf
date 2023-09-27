resource "google_compute_global_address" "ingress" {
  name         = "packagecloud-gke-ingress-${var.environment}"
  description  = "Static IP used by packagecloud ingress"
  address_type = "EXTERNAL"
}

resource "cloudflare_record" "packages-gitlab-com" {
  count = var.cloudflare_zone_id != "" && var.cloudflare_dns_record_name != "" ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_dns_record_name
  value   = coalesce(var.cloudflare_dns_record_value, google_compute_global_address.ingress.address)
  type    = "A"
  proxied = true
}
