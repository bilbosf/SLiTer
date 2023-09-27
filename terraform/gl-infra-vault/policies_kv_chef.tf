// https://www.vaultproject.io/docs/secrets/kv/kv-v2#acl-rules

locals {
  chef_admin_all_policy    = "chef_admin_all"
  chef_readonly_all_policy = "chef_readonly_all"
  chef_list_all_policy     = "chef_list_all"
}

// Chef admin all
data "vault_policy_document" "chef_admin_all" {
  rule {
    path         = "${local.chef_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.chef_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.chef_mount_path}/data/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.chef_mount_path}/metadata/*"
    capabilities = ["create", "read", "update", "patch", "delete", "list"]
  }

  rule {
    path         = "${local.chef_mount_path}/subkeys/*"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.chef_mount_path}/delete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.chef_mount_path}/undelete/*"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.chef_mount_path}/destroy/*"
    capabilities = ["update"]
  }
}

resource "vault_policy" "chef_admin_all" {
  name   = local.chef_admin_all_policy
  policy = data.vault_policy_document.chef_admin_all.hcl
}

// Chef readonly all
data "vault_policy_document" "chef_readonly_all" {
  rule {
    path         = "${local.chef_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.chef_mount_path}/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.chef_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "chef_readonly_all" {
  name   = local.chef_readonly_all_policy
  policy = data.vault_policy_document.chef_readonly_all.hcl
}

// Chef list all
data "vault_policy_document" "chef_list_all" {
  rule {
    path         = "${local.chef_mount_path}/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.chef_mount_path}/metadata/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.chef_mount_path}/data/*"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.chef_mount_path}/subkeys/*"
    capabilities = ["read"]
  }
}

resource "vault_policy" "chef_list_all" {
  name   = local.chef_list_all_policy
  policy = data.vault_policy_document.chef_list_all.hcl
}

data "vault_policy_document" "chef_role" {
  for_each = local.chef_environment_roles

  // Chef roles
  // Chef Environment - env/<environment>/shared/*
  rule {
    path         = "${local.chef_mount_path}/metadata/env/${each.value.environment}/shared/*"
    capabilities = ["list", "read"]
  }

  rule {
    path         = "${local.chef_mount_path}/data/env/${each.value.environment}/shared/*"
    capabilities = ["list", "read"]
  }

  // Cookbook Secrets - env/<env>/cookbook/<cookbook>/*
  dynamic "rule" {
    for_each = toset(each.value.cookbooks)

    content {
      path         = "${local.chef_mount_path}/metadata/env/${each.value.environment}/cookbook/${rule.value}/*"
      capabilities = ["list", "read"]
    }
  }
  dynamic "rule" {
    for_each = toset(each.value.cookbooks)

    content {
      path         = "${local.chef_mount_path}/data/env/${each.value.environment}/cookbook/${rule.value}/*"
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
}

resource "vault_policy" "chef_role" {
  for_each = local.chef_environment_roles

  name   = each.key
  policy = data.vault_policy_document.chef_role[each.key].hcl
}
