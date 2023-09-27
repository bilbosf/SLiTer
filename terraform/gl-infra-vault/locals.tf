locals {
  # OIDC
  oidc_allowed_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "${var.vault_addr}/ui/vault/auth/${vault_jwt_auth_backend.okta.path}/oidc/callback",
    # Public DNS
    "${var.vault_public_addr}/ui/vault/auth/${vault_jwt_auth_backend.okta.path}/oidc/callback",
  ]

  # Empty key used to populate KV paths
  kv_placeholder_file = ".placeholder"

  # Used to split extra secret paths in policies
  vault_kv_v2_expand_regex = "/^(\\w+)\\//"

  # GitLab CI secrets
  ci_mount_path         = "ci"
  ci_transit_mount_path = "transit/ci"
  ci_secrets_paths      = toset(keys(var.ci_secrets_policies))

  # GCP
  gcp_secrets_path                 = "gcp"
  gcp_service_account_email_format = "%s@%s.iam.gserviceaccount.com"

  gcp_impersonated_accounts = {
    for impersonated_account in flatten([
      for project_id, project in var.gcp.projects : [
        for service_account_id, impersonated_account in project.impersonated_accounts : [
          merge(impersonated_account, {
            name               = join("--", [project_id, service_account_id])
            service_account_id = coalesce(impersonated_account.service_account_id, service_account_id)
            project_id         = project_id
            oauth_scopes       = impersonated_account.oauth_scopes
          })
        ]
      ]
    ]) :
    impersonated_account.name => impersonated_account
  }

  gcp_rolesets = {
    for roleset in flatten([
      for project_id, project in var.gcp.projects : [
        for roleset_name, roleset in project.rolesets : [
          merge(roleset, {
            name         = join("--", [project_id, roleset_name])
            project_id   = project_id
            oauth_scopes = roleset.type == "access_token" ? roleset.oauth_scopes : null
          })
        ]
      ]
    ]) :
    roleset.name => roleset
  }

  gcp_static_accounts = {
    for static_account in flatten([
      for project_id, project in var.gcp.projects : [
        for service_account_id, static_account in project.static_accounts : [
          merge(static_account, {
            name               = join("--", [project_id, service_account_id])
            project_id         = project_id
            service_account_id = coalesce(static_account.service_account_id, service_account_id)
            oauth_scopes       = static_account.type == "access_token" ? static_account.oauth_scopes : null
          })
        ]
      ]
    ]) :
    static_account.name => static_account
  }

  # Kubernetes secrets
  kubernetes_mount_path_prefix = "kubernetes"
  kubernetes_kv_mount_path     = "k8s"
  kubernetes_kv_secrets_paths  = toset(keys(var.kubernetes_secrets_policies))

  # Filter out disabled Kubernetes clusters for the secrets engine (service account JWT unset)
  kubernetes_secrets_clusters = {
    for id, cluster in var.kubernetes_clusters :
    id => cluster if nonsensitive(sensitive(cluster.config.service_account_jwt) != null)
  }

  # Kubernetes secrets roles
  kubernetes_secrets_roles = {
    for role in flatten([
      for cluster, cluster_attrs in var.kubernetes_clusters : [
        for role, role_attrs in cluster_attrs.secrets_roles :
        merge(role_attrs, {
          name    = role
          cluster = cluster
        })
      ] if nonsensitive(sensitive(cluster_attrs.config.service_account_jwt) != null)
    ]) : "${role.cluster}:${role.name}" => role
  }

  # Kubernetes KV roles
  kubernetes_kv_roles = {
    for role in flatten([
      for cluster, cluster_attrs in var.kubernetes_clusters : [
        for role_name, role_attrs in cluster_attrs.auth_roles :
        merge(role_attrs, { cluster = cluster, environment = cluster_attrs.environment, role_name = role_name })
      ]
    ]) :
    "${role.cluster}:${role.role_name}" => role
  }
  # Kubernetes KV namespace secret paths
  kubernetes_kv_namespaces = {
    for namespace in toset(flatten([
      for cluster_role, role_attrs in local.kubernetes_kv_roles :
      [for ns in role_attrs.namespaces : { cluster = role_attrs.cluster, namespace = ns }]
    ])) : "${namespace.cluster}:${namespace.namespace}" => namespace
  }

  # Kubernetes KV environment secret paths
  kubernetes_kv_environments = toset([for cluster in var.kubernetes_clusters : cluster.environment])

  # Kubernetes KV environment/namespace secret paths
  kubernetes_kv_env_namespaces = {
    for namespace in toset(flatten([
      for cluster_role, role_attrs in local.kubernetes_kv_roles :
      [for ns in role_attrs.namespaces : { environment = role_attrs.environment, namespace = ns }]
    ])) : "${namespace.environment}:${namespace.namespace}" => namespace
  }

  # Shared secrets
  shared_mount_path    = "shared"
  shared_secrets_paths = toset(keys(var.shared_secrets_policies))

  # CI secrets policies
  ci_secrets_admin_policies = {
    for p in local.ci_secrets_paths : p => data.vault_policy_document.gitlab_ci_identity_admin[p].hcl
  }
  ci_secrets_read_policies = {
    for p in local.ci_secrets_paths : p => data.vault_policy_document.gitlab_ci_identity_read[p].hcl
  }
  ci_secrets_list_policies = {
    for p in keys(var.ci_secrets_policies) : p => data.vault_policy_document.gitlab_ci_identity_list[p].hcl
  }

  # Kubernetes KV secrets policies
  kubernetes_kv_secrets_admin_policies = {
    for p in local.kubernetes_kv_secrets_paths : p => data.vault_policy_document.k8s_identity_admin[p].hcl
  }
  kubernetes_kv_secrets_read_policies = {
    for p in local.kubernetes_kv_secrets_paths : p => data.vault_policy_document.k8s_identity_read[p].hcl
  }
  kubernetes_kv_secrets_list_policies = {
    for p in keys(var.kubernetes_secrets_policies) : p => data.vault_policy_document.k8s_identity_list[p].hcl
  }

  # Shared secrets policies
  shared_secrets_admin_policies = {
    for p in local.shared_secrets_paths : p => data.vault_policy_document.shared_identity_admin[p].hcl
  }
  shared_secrets_read_policies = {
    for p in local.shared_secrets_paths : p => data.vault_policy_document.shared_identity_read[p].hcl
  }
  shared_secrets_list_policies = {
    for p in keys(var.shared_secrets_policies) : p => data.vault_policy_document.shared_identity_list[p].hcl
  }

  # Chef secrets
  chef_mount_path    = "chef"
  chef_secrets_paths = toset(keys(var.chef_secrets_policies))

  # Chef secrets policies
  chef_secrets_admin_policies = {
    for p in local.chef_secrets_paths : p => data.vault_policy_document.chef_identity_admin[p].hcl
  }
  chef_secrets_read_policies = {
    for p in local.chef_secrets_paths : p => data.vault_policy_document.chef_identity_read[p].hcl
  }
  chef_secrets_list_policies = {
    for p in keys(var.chef_secrets_policies) : p => data.vault_policy_document.chef_identity_list[p].hcl
  }

  # Chef GCP Environment Roles
  chef_environment_roles = {
    for role in flatten([
      for environment_name, environment_attrs in var.chef_environments : [
        for role_name, role_attrs in environment_attrs.roles :
        merge(role_attrs, {
          gcp_projects = environment_attrs.gcp_projects
          environment  = environment_name
          role_name    = "chef_${environment_name}_${role_name}"
        })
      ]
    ]) :
    role.role_name => role
  }

  # Chef Cookbooks per environment
  chef_env_cookbooks = {
    for c in toset(flatten([
      for env, env_attrs in var.chef_environments : [
        for role_name, role_attrs in env_attrs.roles : [
          for cookbook in role_attrs.cookbooks : {
            env      = env
            cookbook = cookbook
          }
        ]
      ]
    ])) : "${c.env}:${c.cookbook}" => c
  }

  # Runway secrets
  runway_mount_path    = "runway"
  runway_secrets_paths = toset(keys(var.runway_secrets_policies))

  # Runway secrets policies
  runway_secrets_admin_policies = {
    for p in local.runway_secrets_paths : p => data.vault_policy_document.runway_identity_admin[p].hcl
  }
  runway_secrets_read_policies = {
    for p in local.runway_secrets_paths : p => data.vault_policy_document.runway_identity_read[p].hcl
  }
  runway_secrets_list_policies = {
    for p in keys(var.runway_secrets_policies) : p => data.vault_policy_document.runway_identity_list[p].hcl
  }
}
