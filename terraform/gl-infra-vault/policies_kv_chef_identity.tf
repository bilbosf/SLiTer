locals {
  chef_identity_policy_format = "chef_identity_%s_%s"
}

// Chef path policies - admin
data "vault_policy_document" "chef_identity_admin" {
  for_each = local.chef_secrets_paths

  // Metadata
  rule {
    path         = "${local.chef_mount_path}/metadata/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Data
  rule {
    path         = "${local.chef_mount_path}/data/${each.key}/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.chef_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }

  // Version delete
  rule {
    path         = "${local.chef_mount_path}/delete/${each.key}/*"
    capabilities = ["update"]
  }

  // Version undelete
  rule {
    path         = "${local.chef_mount_path}/undelete/${each.key}/*"
    capabilities = ["update"]
  }

  // Version destroy
  rule {
    path         = "${local.chef_mount_path}/destroy/${each.key}/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "chef_identity_admin" {
  for_each = local.chef_secrets_admin_policies

  name   = format(local.chef_identity_policy_format, base64encode(each.key), "admin")
  policy = each.value
}

// Chef path policies - read
data "vault_policy_document" "chef_identity_read" {
  for_each = local.chef_secrets_paths

  // Metadata
  rule {
    path         = "${local.chef_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.chef_mount_path}/data/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Subkeys
  rule {
    path         = "${local.chef_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "chef_identity_read" {
  for_each = local.chef_secrets_read_policies

  name   = format(local.chef_identity_policy_format, base64encode(each.key), "read")
  policy = each.value
}

// Chef path policies - list
data "vault_policy_document" "chef_identity_list" {
  for_each = local.chef_secrets_paths

  // Metadata
  rule {
    path         = "${local.chef_mount_path}/metadata/${each.key}/*"
    capabilities = ["read", "list"]
  }

  // Data
  rule {
    path         = "${local.chef_mount_path}/data/${each.key}/*"
    capabilities = ["list"]
  }

  // Subkeys
  rule {
    path         = "${local.chef_mount_path}/subkeys/${each.key}/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "chef_identity_list" {
  for_each = local.chef_secrets_list_policies

  name   = format(local.chef_identity_policy_format, base64encode(each.key), "list")
  policy = each.value
}
