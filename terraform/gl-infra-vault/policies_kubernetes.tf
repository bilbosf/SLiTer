// https://www.vaultproject.io/docs/secrets/kv/kv-v2#acl-rules

locals {
  kubernetes_admin_all_policy            = "kubernetes_admin_all"
  kubernetes_list_all_policy             = "kubernetes_list_all"
  kubernetes_admin_cluster_policy_format = "kubernetes_admin_cluster_%s"
  kubernetes_list_cluster_policy_format  = "kubernetes_list_cluster_%s"
  kubernetes_role_policy_format          = "kubernetes_%s--%s"
}

// Kubernetes admin all
data "vault_policy_document" "kubernetes_admin_all" {
  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/roles/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/creds/*"
    capabilities = ["create", "update"]
  }
}

resource "vault_policy" "kubernetes_admin_all" {
  name   = local.kubernetes_admin_all_policy
  policy = data.vault_policy_document.kubernetes_admin_all.hcl
}

// Kubernetes list all
data "vault_policy_document" "kubernetes_list_all" {
  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/roles/"
    capabilities = ["list"]
  }
}

resource "vault_policy" "kubernetes_list_all" {
  name   = local.kubernetes_list_all_policy
  policy = data.vault_policy_document.kubernetes_list_all.hcl
}

// Kubernetes admin single cluster
data "vault_policy_document" "kubernetes_admin_cluster" {
  for_each = local.kubernetes_secrets_clusters

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/${each.key}/roles/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/${each.key}/creds/*"
    capabilities = ["create", "update"]
  }
}

resource "vault_policy" "kubernetes_admin_cluster" {
  for_each = local.kubernetes_secrets_clusters

  name   = format(local.kubernetes_admin_cluster_policy_format, each.key)
  policy = data.vault_policy_document.kubernetes_admin_cluster[each.key].hcl
}

// Kubernetes list single cluster
data "vault_policy_document" "kubernetes_list_cluster" {
  for_each = local.kubernetes_secrets_clusters

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/${each.key}/roles/"
    capabilities = ["list"]
  }
}

resource "vault_policy" "kubernetes_list_cluster" {
  for_each = local.kubernetes_secrets_clusters

  name   = format(local.kubernetes_list_cluster_policy_format, each.key)
  policy = data.vault_policy_document.kubernetes_list_cluster[each.key].hcl
}

// Kubernetes secrets roles
data "vault_policy_document" "kubernetes_role" {
  for_each = local.kubernetes_secrets_roles

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/${each.value.cluster}/creds/${each.value.name}"
    capabilities = ["create", "update"]
  }
}

resource "vault_policy" "kubernetes_role" {
  for_each = local.kubernetes_secrets_roles

  name   = format(local.kubernetes_role_policy_format, each.value.cluster, each.value.name)
  policy = data.vault_policy_document.kubernetes_role[each.key].hcl
}
