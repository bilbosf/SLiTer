locals {
  gcp_list_all_policy                    = "gcp_list_all"
  gcp_admin_all_policy                   = "gcp_admin_all"
  gcp_impersonated_account_policy_format = "gcp_impersonated_account_%s"
  gcp_roleset_policy_format              = "gcp_roleset_%s"
  gcp_static_account_policy_format       = "gcp_static_account_%s"
}

// GCP admin all
data "vault_policy_document" "gcp_admin_all" {
  rule {
    path         = "${local.gcp_secrets_path}/impersonated-account/+/token"
    capabilities = ["create", "read", "update"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/+/key"
    capabilities = ["create", "read", "update"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/+/token"
    capabilities = ["create", "read", "update"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/static-account/+/key"
    capabilities = ["create", "read", "update"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/static-account/+/token"
    capabilities = ["create", "read", "update"]
  }
}

resource "vault_policy" "gcp_admin_all" {
  name   = local.gcp_admin_all_policy
  policy = data.vault_policy_document.gcp_admin_all.hcl
}

# GCP list all
data "vault_policy_document" "gcp_list_all" {
  rule {
    path         = "${local.gcp_secrets_path}/impersonated-account/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/static-account/"
    capabilities = ["list"]
  }
}

resource "vault_policy" "gcp_list_all" {
  name   = local.gcp_list_all_policy
  policy = data.vault_policy_document.gcp_list_all.hcl
}

data "vault_policy_document" "gcp_impersonated_account" {
  for_each = local.gcp_impersonated_accounts

  rule {
    path = join("/", [
      local.gcp_secrets_path,
      "impersonated-account",
      vault_gcp_secret_impersonated_account.account[each.key].impersonated_account,
      "token"
    ])
    capabilities = ["create", "read", "update"]
  }
}

resource "vault_policy" "gcp_impersonated_account" {
  for_each = local.gcp_impersonated_accounts

  name   = format(local.gcp_impersonated_account_policy_format, each.key)
  policy = data.vault_policy_document.gcp_impersonated_account[each.key].hcl
}

data "vault_policy_document" "gcp_roleset" {
  for_each = local.gcp_rolesets

  rule {
    path = join("/", [
      local.gcp_secrets_path,
      "roleset",
      vault_gcp_secret_roleset.roleset[each.key].roleset,
      each.value.type == "access_token" ? "token" : "key"
    ])
    capabilities = ["create", "read", "update"]
  }
}

resource "vault_policy" "gcp_roleset" {
  for_each = local.gcp_rolesets

  name   = format(local.gcp_roleset_policy_format, each.key)
  policy = data.vault_policy_document.gcp_roleset[each.key].hcl
}

data "vault_policy_document" "gcp_static_account" {
  for_each = local.gcp_static_accounts

  rule {
    path = join("/", [
      local.gcp_secrets_path,
      "static-account",
      vault_gcp_secret_static_account.account[each.key].static_account,
      each.value.type == "access_token" ? "token" : "key"
    ])
    capabilities = ["create", "read", "update"]
  }
}

resource "vault_policy" "gcp_static_account" {
  for_each = local.gcp_static_accounts

  name   = format(local.gcp_static_account_policy_format, each.key)
  policy = data.vault_policy_document.gcp_static_account[each.key].hcl
}
