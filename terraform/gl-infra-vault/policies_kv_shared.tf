
// https://www.vaultproject.io/docs/secrets/kv/kv-v2#acl-rules

locals {
  shared_admin_all_policy    = "shared_admin_all"
  shared_readonly_all_policy = "shared_readonly_all"
  shared_list_all_policy     = "shared_list_all"
}

// Shared admin all
data "vault_policy_document" "shared_admin_all" {
  rule {
    path         = "${local.shared_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.shared_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.shared_mount_path}/data/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.shared_mount_path}/metadata/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.shared_mount_path}/subkeys/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.shared_mount_path}/delete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.shared_mount_path}/undelete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.shared_mount_path}/destroy/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "shared_admin_all" {
  name   = local.shared_admin_all_policy
  policy = data.vault_policy_document.shared_admin_all.hcl
}

// Shared readonly all
data "vault_policy_document" "shared_readonly_all" {
  rule {
    path         = "${local.shared_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.shared_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.shared_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "shared_readonly_all" {
  name   = local.shared_readonly_all_policy
  policy = data.vault_policy_document.shared_readonly_all.hcl
}

// Shared list all
data "vault_policy_document" "shared_list_all" {
  rule {
    path         = "${local.shared_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.shared_mount_path}/metadata/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.shared_mount_path}/data/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.shared_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "shared_list_all" {
  name   = local.shared_list_all_policy
  policy = data.vault_policy_document.shared_list_all.hcl
}
