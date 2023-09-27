locals {
  shared_identity_policy_format = "shared_identity_%s_%s"
}

// Shared path policies - admin
data "vault_policy_document" "shared_identity_admin" {
  for_each = local.shared_secrets_paths

  // Metadata
  rule {
    path         = "${local.shared_mount_path}/metadata/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Data
  rule {
    path         = "${local.shared_mount_path}/data/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.shared_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }

  // Version delete
  rule {
    path         = "${local.shared_mount_path}/delete/*"
    capabilities = ["update"]
  }

  // Version undelete
  rule {
    path         = "${local.shared_mount_path}/undelete/*"
    capabilities = ["update"]
  }

  // Version destroy
  rule {
    path         = "${local.shared_mount_path}/destroy/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "shared_identity_admin" {
  for_each = local.shared_secrets_admin_policies

  name   = format(local.shared_identity_policy_format, base64encode(each.key), "admin")
  policy = each.value
}

// Shared path policies - read
data "vault_policy_document" "shared_identity_read" {
  for_each = local.shared_secrets_paths

  // Metadata
  rule {
    path         = "${local.shared_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.shared_mount_path}/data/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.shared_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "shared_identity_read" {
  for_each = local.shared_secrets_read_policies

  name   = format(local.shared_identity_policy_format, base64encode(each.key), "read")
  policy = each.value
}

// Shared path policies - list
data "vault_policy_document" "shared_identity_list" {
  for_each = local.shared_secrets_paths

  // Metadata
  rule {
    path         = "${local.shared_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.shared_mount_path}/data/${each.key}/*"
    capabilities = ["list"]
  }

  // Subkeys
  rule {
    path         = "${local.shared_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "shared_identity_list" {
  for_each = local.shared_secrets_list_policies

  name   = format(local.shared_identity_policy_format, base64encode(each.key), "list")
  policy = each.value
}
