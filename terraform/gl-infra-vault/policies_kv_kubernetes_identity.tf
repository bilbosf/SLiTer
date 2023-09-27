locals {
  k8s_identity_policy_format = "k8s_identity_%s_%s"
}

// Kubernetes KV path policies - admin
data "vault_policy_document" "k8s_identity_admin" {
  for_each = local.kubernetes_kv_secrets_paths

  // Metadata
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Data
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }

  // Version delete
  rule {
    path         = "${local.kubernetes_kv_mount_path}/delete/${each.key}/*"
    capabilities = ["update"]
  }

  // Version undelete
  rule {
    path         = "${local.kubernetes_kv_mount_path}/undelete/${each.key}/*"
    capabilities = ["update"]
  }

  // Version destroy
  rule {
    path         = "${local.kubernetes_kv_mount_path}/destroy/${each.key}/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "k8s_identity_admin" {
  for_each = local.kubernetes_kv_secrets_admin_policies

  name   = format(local.k8s_identity_policy_format, base64encode(each.key), "admin")
  policy = each.value
}

// Kubernetes KV path policies - read
data "vault_policy_document" "k8s_identity_read" {
  for_each = local.kubernetes_kv_secrets_paths

  // Metadata
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "k8s_identity_read" {
  for_each = local.kubernetes_kv_secrets_read_policies

  name   = format(local.k8s_identity_policy_format, base64encode(each.key), "read")
  policy = each.value
}

// Kubernetes KV path policies - list
data "vault_policy_document" "k8s_identity_list" {
  for_each = local.kubernetes_kv_secrets_paths

  // Metadata
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/${each.key}/*"
    capabilities = ["list"]
  }

  // Subkeys
  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "k8s_identity_list" {
  for_each = local.kubernetes_kv_secrets_list_policies

  name   = format(local.k8s_identity_policy_format, base64encode(each.key), "list")
  policy = each.value
}
