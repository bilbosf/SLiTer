// https://www.vaultproject.io/docs/secrets/kv/kv-v2#acl-rules

locals {
  ci_admin_all_policy    = "ci_admin_all"
  ci_readonly_all_policy = "ci_readonly_all"
  ci_list_all_policy     = "ci_list_all"
}

// GitLab admin all
data "vault_policy_document" "ci_admin_all" {
  rule {
    path         = "${local.ci_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.ci_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.ci_mount_path}/data/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.ci_mount_path}/metadata/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.ci_mount_path}/subkeys/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.ci_mount_path}/delete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.ci_mount_path}/undelete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.ci_mount_path}/destroy/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.ci_transit_mount_path}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
}

resource "vault_policy" "ci_admin_all" {
  name   = local.ci_admin_all_policy
  policy = data.vault_policy_document.ci_admin_all.hcl
}

// GitLab readonly all
data "vault_policy_document" "ci_readonly_all" {
  rule {
    path         = "${local.ci_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.ci_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.ci_mount_path}/subkeys/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.ci_transit_mount_path}/keys/*"
    capabilities = ["read", "list"]
  }
}

resource "vault_policy" "ci_readonly_all" {
  name   = local.ci_readonly_all_policy
  policy = data.vault_policy_document.ci_readonly_all.hcl
}

// GitLab list all
data "vault_policy_document" "ci_list_all" {
  rule {
    path         = "${local.ci_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.ci_mount_path}/metadata/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.ci_mount_path}/data/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.ci_mount_path}/subkeys/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.ci_transit_mount_path}/keys/*"
    capabilities = ["list"]
  }
}

resource "vault_policy" "ci_list_all" {
  name   = local.ci_list_all_policy
  policy = data.vault_policy_document.ci_list_all.hcl
}

# GitLab management readonly policy
data "vault_policy_document" "gitlab-management" {
  for_each = var.jwt_auth_backends

  # Read authentication methods (eg. to get accessors)
  rule {
    path         = "sys/auth"
    capabilities = ["read"]
  }

  # Manage project roles
  rule {
    path         = "auth/${each.key}/role/*"
    capabilities = ["read", "list"]
  }

  # Manage project policies
  rule {
    path         = "sys/policies/acl/${each.key}-project-*"
    capabilities = ["read", "list"]
  }

  // ci/<host>/<repo>/<placeholder_file>
  dynamic "rule" {
    for_each = [for d in range(1, var.ci_secrets_path_max_depth) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/metadata/${each.key}/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["read", "list"]
    }
  }

  dynamic "rule" {
    for_each = [for d in range(1, var.ci_secrets_path_max_depth) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/data/${each.key}/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["read", "list"]
    }
  }

  rule {
    path         = "${local.ci_transit_mount_path}/keys/${each.key}-*"
    capabilities = ["read", "list"]
  }
}

resource "vault_policy" "gitlab-management" {
  for_each = var.jwt_auth_backends

  name   = "${each.key}-gitlab-management"
  policy = data.vault_policy_document.gitlab-management[each.key].hcl
}

# GitLab management policy
data "vault_policy_document" "gitlab-management-rw" {
  for_each = var.jwt_auth_backends

  # Read authentication methods (eg. to get accessors)
  rule {
    path         = "sys/auth"
    capabilities = ["read"]
  }

  # Manage project roles
  rule {
    path         = "auth/${each.key}/role/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  # Manage project policies
  rule {
    path         = "sys/policies/acl/${each.key}-project-*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  // ci/<host>/<repo>/<placeholder_file>
  dynamic "rule" {
    for_each = [for d in range(1, var.ci_secrets_path_max_depth) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/metadata/${each.key}/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["create", "read", "update", "delete"]
    }
  }

  dynamic "rule" {
    for_each = [for d in range(1, var.ci_secrets_path_max_depth) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/data/${each.key}/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["create", "read", "update", "delete"]
    }
  }

  rule {
    path         = "${local.ci_transit_mount_path}/keys/${each.key}-*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
}

resource "vault_policy" "gitlab-management-rw" {
  for_each = var.jwt_auth_backends

  name   = "${each.key}-gitlab-management-rw"
  policy = data.vault_policy_document.gitlab-management-rw[each.key].hcl
}
