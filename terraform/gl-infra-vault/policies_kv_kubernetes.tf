// https://www.vaultproject.io/docs/secrets/kv/kv-v2#acl-rules

locals {
  k8s_admin_all_policy               = "k8s_admin_all"
  k8s_readonly_all_policy            = "k8s_readonly_all"
  k8s_list_all_policy                = "k8s_list_all"
  k8s_role_policy_format             = "k8s_%s_%s"
  k8s_readonly_cluster_policy_format = "k8s_readonly_cluster_%s"
}

// Kubernetes KV admin all
data "vault_policy_document" "k8s_admin_all" {
  rule {
    path         = "${local.kubernetes_kv_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/delete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/undelete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/destroy/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "k8s_admin_all" {
  name   = local.k8s_admin_all_policy
  policy = data.vault_policy_document.k8s_admin_all.hcl
}

// Kubernetes KV readonly all
data "vault_policy_document" "k8s_readonly_all" {
  rule {
    path         = "${local.kubernetes_kv_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "k8s_readonly_all" {
  name   = local.k8s_readonly_all_policy
  policy = data.vault_policy_document.k8s_readonly_all.hcl
}

// Kubernetes KV list all
data "vault_policy_document" "k8s_list_all" {
  rule {
    path         = "${local.kubernetes_kv_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "k8s_list_all" {
  name   = local.k8s_list_all_policy
  policy = data.vault_policy_document.k8s_list_all.hcl
}

// Kubernetes KV readonly cluster
data "vault_policy_document" "k8s_readonly_cluster" {
  for_each = var.kubernetes_clusters

  // Cluster
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/${each.key}/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }

  // Environment secrets - <env>/*
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/env/${each.value.environment}/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/env/${each.value.environment}/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/subkeys/env/${each.value.environment}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "k8s_readonly_cluster" {
  for_each = setunion(keys(var.kubernetes_clusters))

  name   = format(local.k8s_readonly_cluster_policy_format, each.key)
  policy = data.vault_policy_document.k8s_readonly_cluster[each.key].hcl
}

// Kubernetes KV roles
data "vault_policy_document" "k8s_role" {
  for_each = local.kubernetes_kv_roles

  // Cluster namespace - <cluster>/<namespace>/*
  dynamic "rule" {
    for_each = toset(each.value.namespaces)

    content {
      path         = "${local.kubernetes_kv_mount_path}/metadata/${each.value.cluster}/${replace(rule.value, "*", "+")}/*"
      capabilities = ["list", "read"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.namespaces)

    content {
      path         = "${local.kubernetes_kv_mount_path}/data/${each.value.cluster}/${replace(rule.value, "*", "+")}/*"
      capabilities = ["list", "read"]
    }
  }

  // Environment secrets - env/<env>/ns/<namespace>/*
  dynamic "rule" {
    for_each = toset(each.value.namespaces)

    content {
      path         = "${local.kubernetes_kv_mount_path}/metadata/env/${each.value.environment}/ns/${replace(rule.value, "*", "+")}/*"
      capabilities = ["list", "read"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.namespaces)

    content {
      path         = "${local.kubernetes_kv_mount_path}/data/env/${each.value.environment}/ns/${replace(rule.value, "*", "+")}/*"
      capabilities = ["list", "read"]
    }
  }

  # Extra secrets
  dynamic "rule" {
    for_each = toset(each.value.readonly_secret_paths)
    content {
      # rebuilding the extra path to insert data/
      path         = replace(rule.value, local.vault_kv_v2_expand_regex, "$1/data/")
      capabilities = ["list", "read"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.readonly_secret_paths)
    content {
      # rebuilding the extra path to insert metadata/
      path         = replace(rule.value, local.vault_kv_v2_expand_regex, "$1/metadata/")
      capabilities = ["list", "read"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.readwrite_secret_paths)
    content {
      # rebuilding the extra path to insert data/
      path         = replace(rule.value, local.vault_kv_v2_expand_regex, "$1/data/")
      capabilities = ["list", "read", "create", "patch", "update", "delete"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.readwrite_secret_paths)
    content {
      # rebuilding the extra path to insert metadata/
      path         = replace(rule.value, local.vault_kv_v2_expand_regex, "$1/metadata/")
      capabilities = ["list", "read", "create", "patch", "update", "delete"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.readwrite_secret_paths)
    content {
      # rebuilding the extra path to insert delete/
      path         = replace(rule.value, local.vault_kv_v2_expand_regex, "$1/delete/")
      capabilities = ["update"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.readwrite_secret_paths)
    content {
      # rebuilding the extra path to insert undelete/
      path         = replace(rule.value, local.vault_kv_v2_expand_regex, "$1/undelete/")
      capabilities = ["update"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.readwrite_secret_paths)
    content {
      # rebuilding the extra path to insert destroy/
      path         = replace(rule.value, local.vault_kv_v2_expand_regex, "$1/destroy/")
      capabilities = ["update"]
    }
  }
}

resource "vault_policy" "k8s_role" {
  for_each = local.kubernetes_kv_roles

  name   = format(local.k8s_role_policy_format, each.value.cluster, each.value.role_name)
  policy = data.vault_policy_document.k8s_role[each.key].hcl
}
