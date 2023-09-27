resource "vault_auth_backend" "kubernetes" {
  for_each = var.kubernetes_clusters

  path        = "kubernetes/${each.key}"
  type        = "kubernetes"
  description = "Kubernetes cluster ${each.key}"

  tune {
    listing_visibility = "hidden"
    default_lease_ttl  = "1h"
    max_lease_ttl      = "3h"
    // https://www.vaultproject.io/docs/concepts/tokens
    token_type = "default-service"
  }
}

resource "vault_kubernetes_auth_backend_config" "cluster" {
  for_each = var.kubernetes_clusters

  backend            = vault_auth_backend.kubernetes[each.key].path
  kubernetes_host    = each.value.config.host
  kubernetes_ca_cert = each.value.config.ca_cert
  token_reviewer_jwt = each.value.config.token_reviewer_jwt
  // Kubernetes >= 1.21 https://www.vaultproject.io/docs/auth/kubernetes#kubernetes-1-21
  disable_iss_validation = true
  // https://developer.hashicorp.com/vault/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt
  disable_local_ca_jwt = true
}
