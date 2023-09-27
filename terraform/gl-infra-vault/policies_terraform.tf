locals {
  terraform_policy = "terraform"
}

# Terraform basic policy
data "vault_policy_document" "terraform" {
  # Terraform vault provider creates a short lived session
  rule {
    path         = "auth/token/create"
    capabilities = ["update"]
  }
}

resource "vault_policy" "terraform" {
  name   = local.terraform_policy
  policy = data.vault_policy_document.terraform.hcl
}
