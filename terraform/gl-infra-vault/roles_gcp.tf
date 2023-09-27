resource "vault_gcp_auth_backend_role" "raft-snapshots" {
  backend = vault_auth_backend.gcp.path

  role = "raft-snapshots"
  type = "iam"

  bound_service_accounts = [var.raft_snapshots_service_account]

  token_policies = [vault_policy.raft-snapshots.name]
}
