locals {
  runway_identity_policy_format = "runway_identity_%s_%s"
}

// Runway path policies - admin
data "vault_policy_document" "runway_identity_admin" {
  for_each = local.runway_secrets_paths

  // Metadata
  rule {
    path         = "${local.runway_mount_path}/metadata/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Data
  rule {
    path         = "${local.runway_mount_path}/data/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.runway_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }

  // Version delete
  rule {
    path         = "${local.runway_mount_path}/delete/${each.key}/*"
    capabilities = ["update"]
  }

  // Version undelete
  rule {
    path         = "${local.runway_mount_path}/undelete/${each.key}/*"
    capabilities = ["update"]
  }

  // Version destroy
  rule {
    path         = "${local.runway_mount_path}/destroy/${each.key}/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "runway_identity_admin" {
  for_each = local.runway_secrets_admin_policies

  name   = format(local.runway_identity_policy_format, base64encode(each.key), "admin")
  policy = each.value
}

// Runway path policies - read
data "vault_policy_document" "runway_identity_read" {
  for_each = local.runway_secrets_paths

  // Metadata
  rule {
    path         = "${local.runway_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.runway_mount_path}/data/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.runway_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "runway_identity_read" {
  for_each = local.runway_secrets_read_policies

  name   = format(local.runway_identity_policy_format, base64encode(each.key), "read")
  policy = each.value
}

// Runway path policies - list
data "vault_policy_document" "runway_identity_list" {
  for_each = local.runway_secrets_paths

  // Metadata
  rule {
    path         = "${local.runway_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.runway_mount_path}/data/${each.key}/*"
    capabilities = ["list"]
  }

  // Subkeys
  rule {
    path         = "${local.runway_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "runway_identity_list" {
  for_each = local.runway_secrets_list_policies

  name   = format(local.runway_identity_policy_format, base64encode(each.key), "list")
  policy = each.value
}
