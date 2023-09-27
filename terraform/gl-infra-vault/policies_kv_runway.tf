// https://www.vaultproject.io/docs/secrets/kv/kv-v2#acl-rules

locals {
  runway_admin_all_policy    = "runway_admin_all"
  runway_readonly_all_policy = "runway_readonly_all"
  runway_list_all_policy     = "runway_list_all"
}

// Runway admin all
data "vault_policy_document" "runway_admin_all" {
  rule {
    path         = "${local.runway_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.runway_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.runway_mount_path}/data/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.runway_mount_path}/metadata/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.runway_mount_path}/subkeys/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.runway_mount_path}/delete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.runway_mount_path}/undelete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.runway_mount_path}/destroy/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "runway_admin_all" {
  name   = local.runway_admin_all_policy
  policy = data.vault_policy_document.runway_admin_all.hcl
}

// Runway readonly all
data "vault_policy_document" "runway_readonly_all" {
  rule {
    path         = "${local.runway_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.runway_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.runway_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "runway_readonly_all" {
  name   = local.runway_readonly_all_policy
  policy = data.vault_policy_document.runway_readonly_all.hcl
}

// Runway list all
data "vault_policy_document" "runway_list_all" {
  rule {
    path         = "${local.runway_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.runway_mount_path}/metadata/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.runway_mount_path}/data/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.runway_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "runway_list_all" {
  name   = local.runway_list_all_policy
  policy = data.vault_policy_document.runway_list_all.hcl
}

# Runway provisioner readonly policy
data "vault_policy_document" "runway-provisioner" {
  for_each = var.jwt_auth_backends

  # Read authentication methods (eg. to get accessors)
  rule {
    path         = "sys/auth"
    capabilities = ["read"]
  }

  # Manage runway service roles
  rule {
    path         = "auth/${each.key}/role/runway-*"
    capabilities = ["read", "list"]
  }

  # Manage runway service policies
  rule {
    path         = "sys/policies/acl/${each.key}-runway-*"
    capabilities = ["read", "list"]
  }

  // runway/env/<env>/service/<service>/<placeholder_file>
  rule {
    path         = "${local.runway_mount_path}/metadata/env/+/service/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.runway_mount_path}/data/env/+/service/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
}

resource "vault_policy" "runway-provisioner" {
  for_each = var.jwt_auth_backends

  name   = "${each.key}-runway-provisioner"
  policy = data.vault_policy_document.runway-provisioner[each.key].hcl
}

# Runway provisioner policy
data "vault_policy_document" "runway-provisioner-rw" {
  for_each = var.jwt_auth_backends

  # Read authentication methods (eg. to get accessors)
  rule {
    path         = "sys/auth"
    capabilities = ["read"]
  }

  # Manage runway service roles
  rule {
    path         = "auth/${each.key}/role/runway-*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  # Manage runway service policies
  rule {
    path         = "sys/policies/acl/${each.key}-runway-*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  // runway/env/<env>/service/<service>/<placeholder_file>
  rule {
    path         = "${local.runway_mount_path}/metadata/env/+/service/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete"]
  }
  rule {
    path         = "${local.runway_mount_path}/data/env/+/service/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete"]
  }
}

resource "vault_policy" "runway-provisioner-rw" {
  for_each = var.jwt_auth_backends

  name   = "${each.key}-runway-provisioner-rw"
  policy = data.vault_policy_document.runway-provisioner-rw[each.key].hcl
}
