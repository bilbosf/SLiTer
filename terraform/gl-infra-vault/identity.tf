// Okta groups

locals {
  default_admin_policies = [
    vault_policy.chef_admin_all.name,
    vault_policy.ci_admin_all.name,
    vault_policy.gcp_admin_all.name,
    vault_policy.k8s_admin_all.name,
    vault_policy.kubernetes_admin_all.name,
    vault_policy.shared_admin_all.name,
    vault_policy.runway_admin_all.name,
  ]
  /*
  default_readonly_policies = [
    vault_policy.chef_readonly_all.name,
    vault_policy.ci_readonly_all.name,
    vault_policy.k8s_readonly_all.name,
    vault_policy.shared_readonly_all.name,
  ]
  */

  default_okta_groups = {
    for group in var.admin_groups :
    group => local.default_admin_policies
  }

  # Default policies for groups
  default_identity_group_policies = [
    # Chef secrets listing
    vault_policy.chef_list_all.name,
    # CI secrets listing
    vault_policy.ci_list_all.name,
    # GCP secrets listing
    vault_policy.gcp_list_all.name,
    # Kubernetes KV secrets listing
    vault_policy.k8s_list_all.name,
    # Kubernetes roles listing
    vault_policy.kubernetes_list_all.name,
    # Shared secrets listing
    vault_policy.shared_list_all.name,
    # Runway secrets listing
    vault_policy.runway_list_all.name,
    # Terraform policy to allow creating child tokens
    vault_policy.terraform.name,
  ]

  okta_mount_accessor = vault_jwt_auth_backend.okta.accessor

  okta_groups = setunion(
    var.admin_groups,
    var.user_groups,
    flatten([for p in var.chef_secrets_policies : [for role in p : role.groups]]),
    flatten([for p in var.ci_secrets_policies : [for role in p : role.groups]]),
    flatten([for p in var.kubernetes_secrets_policies : [for role in p : role.groups]]),
    flatten([for p in var.shared_secrets_policies : [for role in p : role.groups]]),
    flatten([for project in var.gcp_policies : setunion(
      [for roleset in project.rolesets : roleset.groups],
      [for service_account in project.impersonated_accounts : service_account.groups],
      [for service_account in project.static_accounts : service_account.groups])]
    ),
    flatten([for cluster in var.kubernetes_policies : [for role in cluster.roles : role.groups]]),
  )

  okta_groups_policies = {
    for group in local.okta_groups :
    group => setunion(
      # Default policies for groups
      lookup(local.default_okta_groups, group, []),
      local.default_identity_group_policies,
      # Chef secrets roles
      [
        for pair in setproduct(keys(var.chef_secrets_policies), ["admin", "read", "list"]) :
        format(local.chef_identity_policy_format, base64encode(pair[0]), pair[1])
        if contains(var.chef_secrets_policies[pair[0]][pair[1]].groups, group)
      ],
      # CI secrets roles
      [
        for pair in setproduct(keys(var.ci_secrets_policies), ["admin", "read", "list"]) :
        format(local.gitlab_ci_identity_policy_format, base64encode(pair[0]), pair[1])
        if contains(var.ci_secrets_policies[pair[0]][pair[1]].groups, group)
      ],
      # Kubernetes KV secrets roles
      [
        for pair in setproduct(keys(var.kubernetes_secrets_policies), ["admin", "read", "list"]) :
        format(local.k8s_identity_policy_format, base64encode(pair[0]), pair[1])
        if contains(var.kubernetes_secrets_policies[pair[0]][pair[1]].groups, group)
      ],
      # Shared secrets roles
      [
        for pair in setproduct(keys(var.shared_secrets_policies), ["admin", "read", "list"]) :
        format(local.shared_identity_policy_format, base64encode(pair[0]), pair[1])
        if contains(var.shared_secrets_policies[pair[0]][pair[1]].groups, group)
      ],
      # GCP impersonated accounts, rolesets and static accounts
      flatten([
        for project_id, project in var.gcp_policies : setunion(
          [
            for service_account_id, impersonated_account in project.impersonated_accounts :
            format(local.gcp_impersonated_account_policy_format, join("--", [project_id, service_account_id]))
            if contains(impersonated_account.groups, group)
          ],
          [
            for roleset_name, roleset in project.rolesets :
            format(local.gcp_roleset_policy_format, join("--", [project_id, roleset_name]))
            if contains(roleset.groups, group)
          ],
          [
            for service_account_id, static_account in project.static_accounts :
            format(local.gcp_static_account_policy_format, join("--", [project_id, service_account_id]))
            if contains(static_account.groups, group)
          ],
        )
      ]),
      # Kubernetes roles
      flatten([
        for cluster_name, cluster in var.kubernetes_policies : [
          for role_name, role in cluster.roles :
          format(local.kubernetes_role_policy_format, [cluster_name, role_name])
          if contains(role.groups, group)
        ]
      ]),
    )
  }
}

resource "vault_identity_group" "okta_group" {
  for_each = local.okta_groups

  name = each.key
  type = "external"

  external_policies = true
}

resource "vault_identity_group_alias" "okta_group" {
  for_each = {
    for group in local.okta_groups :
    group => vault_identity_group.okta_group[group].id
  }

  name           = each.key
  mount_accessor = local.okta_mount_accessor
  canonical_id   = each.value
}

resource "vault_identity_group_policies" "policies" {
  for_each = local.okta_groups_policies

  group_id  = vault_identity_group.okta_group[each.key].id
  policies  = each.value
  exclusive = false
}
