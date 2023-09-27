resource "vault_approle_auth_backend_role" "provisioning" {
  backend = vault_auth_backend.approle.path

  role_name = "vault-provisioning"

  token_policies = [
    vault_policy.vault-provisioning.name
  ]
}

resource "vault_approle_auth_backend_role" "role" {
  for_each = var.vault_approle_roles

  backend = vault_auth_backend.approle.path

  role_name = each.key

  token_policies = each.value.token_policies
}
