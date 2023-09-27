// Admin
data "vault_policy_document" "admin" {
  rule {
    path         = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/impersonated-account/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/+/rotate"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/+/rotate-key"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/static-account/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/static-account/+/rotate-key"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/config"
    capabilities = ["read", "update"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/roles/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "identity/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "sys/audit"
    capabilities = ["read", "sudo"]
  }

  rule {
    path         = "sys/audit/*"
    capabilities = ["create", "update", "delete", "sudo"]
  }

  rule {
    path         = "sys/audit-hash/*"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/auth"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/auth/*"
    capabilities = ["create", "read", "update", "delete", "sudo"]
  }

  rule {
    path         = "sys/capabilities"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/capabilities-accessor"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/key-status"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/ha-status"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/leader"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/leases/*"
    capabilities = ["create", "update", "list", "sudo"]
  }

  rule {
    path         = "sys/monitor"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/mounts"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "sys/policies/acl/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "sys/remount"
    capabilities = ["create", "update"]
  }

  rule {
    path         = "sys/seal-status"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/step-down"
    capabilities = ["update", "sudo"]
  }

  rule {
    path         = "sys/storage/raft/configuration"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/storage/raft/snapshot"
    capabilities = ["read", "update"]
  }

  rule {
    path         = "sys/storage/raft/snapshot-force"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/storage/raft/autopilot/*"
    capabilities = ["read", "update"]
  }

  rule {
    path         = "sys/version-history"
    capabilities = ["list"]
  }

  rule {
    path         = "${local.ci_transit_mount_path}/keys/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = data.vault_policy_document.admin.hcl
}

// Readonly
data "vault_policy_document" "readonly" {
  rule {
    path         = "auth/*"
    capabilities = ["read", "list", "sudo"]
  }

  rule {
    path         = "auth/token/create"
    capabilities = ["update"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/impersonated-account/+"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/+"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/static-account/+"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/config"
    capabilities = ["read"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/roles/+"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "identity/entity/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "identity/entity-alias/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "identity/group/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "identity/group-alias/*"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "identity/lookup/*"
    capabilities = ["create", "read", "update", "list"]
  }

  rule {
    path         = "sys/audit"
    capabilities = ["read", "sudo"]
  }

  rule {
    path         = "sys/auth"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/auth/*"
    capabilities = ["read", "sudo"]
  }

  rule {
    path         = "sys/leases/*"
    capabilities = ["list", "sudo"]
  }

  rule {
    path         = "sys/mounts"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/mounts/*"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "sys/policies/acl/*"
    capabilities = ["read", "list"]
  }

  // ci/<host>/<repo>/<placeholder_file>
  dynamic "rule" {
    for_each = [for d in range(2, var.ci_secrets_path_max_depth + 1) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/metadata/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["read", "list"]
    }
  }

  dynamic "rule" {
    for_each = [for d in range(2, var.ci_secrets_path_max_depth + 1) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/data/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["read", "list"]
    }
  }

  // k8s/<cluster>/<namespace>/<placeholder_file>
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/+/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/+/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }

  // k8s/env/<env>/<placeholder_file>
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/env/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/env/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }

  // k8s/env/<env>/ns/<namespace>/<placeholder_file>
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/env/+/ns/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/env/+/ns/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }

  // chef/env/<env>/<placeholder_file>
  rule {
    path         = "${local.chef_mount_path}/metadata/env/+/shared/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.chef_mount_path}/data/env/+/shared/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
  // chef/env/<env>/cookbook/<cookbook>/<placeholder_file>
  rule {
    path         = "${local.chef_mount_path}/metadata/env/+/cookbook/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }
  rule {
    path         = "${local.chef_mount_path}/data/env/+/cookbook/+/${local.kv_placeholder_file}"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "${local.ci_transit_mount_path}/keys/*"
    capabilities = ["read", "list"]
  }
}

resource "vault_policy" "readonly" {
  name   = "readonly"
  policy = data.vault_policy_document.readonly.hcl
}

// Vault provisioning via Terraform
data "vault_policy_document" "vault-provisioning" {
  rule {
    path         = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/impersonated-account/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/roleset/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "${local.gcp_secrets_path}/static-account/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/config"
    capabilities = ["read", "update"]
  }

  rule {
    path         = "${local.kubernetes_mount_path_prefix}/+/roles/+"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "identity/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "sys/audit"
    capabilities = ["read", "sudo"]
  }

  rule {
    path         = "sys/audit/*"
    capabilities = ["create", "update", "delete", "sudo"]
  }

  rule {
    path         = "sys/auth"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/auth/*"
    capabilities = ["create", "read", "update", "delete", "sudo"]
  }

  rule {
    path         = "sys/mounts"
    capabilities = ["read"]
  }

  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "sys/policies/acl/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "sys/storage/raft/autopilot/configuration"
    capabilities = ["read", "update"]
  }

  rule {
    path         = "sys/remount"
    capabilities = ["create", "update"]
  }

  // ci/<host>/<repo>/<placeholder_file>
  dynamic "rule" {
    for_each = [for d in range(2, var.ci_secrets_path_max_depth + 1) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/metadata/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  }

  dynamic "rule" {
    for_each = [for d in range(2, var.ci_secrets_path_max_depth + 1) : join("/", [for i in range(d) : "+"])]

    content {
      path         = "${local.ci_mount_path}/data/${rule.value}/${local.kv_placeholder_file}"
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  }

  // k8s/<cluster>/<namespace>/<placeholder_file>
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/+/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/+/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  // k8s/env/<env>/<placeholder_file>
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/env/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/env/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  // k8s/env/<env>/ns/<namespace>/<placeholder_file>
  rule {
    path         = "${local.kubernetes_kv_mount_path}/metadata/env/+/ns/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
  rule {
    path         = "${local.kubernetes_kv_mount_path}/data/env/+/ns/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  // chef/env/<env>/<placeholder_file>
  rule {
    path         = "${local.chef_mount_path}/metadata/env/+/shared/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
  rule {
    path         = "${local.chef_mount_path}/data/env/+/shared/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
  // chef/env/<env>/cookbook/<cookbook>/<placeholder_file>
  rule {
    path         = "${local.chef_mount_path}/metadata/env/+/cookbook/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
  rule {
    path         = "${local.chef_mount_path}/data/env/+/cookbook/+/${local.kv_placeholder_file}"
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  rule {
    path         = "${local.ci_transit_mount_path}/keys/*"
    capabilities = ["create", "read", "update", "delete", "list"]
  }
}

resource "vault_policy" "vault-provisioning" {
  name   = "vault-provisioning"
  policy = data.vault_policy_document.vault-provisioning.hcl
}

// Raft snapshots
data "vault_policy_document" "raft-snapshots" {
  rule {
    path         = "/sys/storage/raft/snapshot"
    capabilities = ["read"]
  }
}

resource "vault_policy" "raft-snapshots" {
  name   = "raft-snapshots"
  policy = data.vault_policy_document.raft-snapshots.hcl
}

// Other policies
resource "vault_policy" "policy" {
  for_each = var.vault_policies

  name   = each.key
  policy = jsonencode(each.value)
}
