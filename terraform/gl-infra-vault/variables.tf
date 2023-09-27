// Infrastructure
variable "vault_addr" {
  type        = string
  description = "Vault server URL."
}

variable "vault_public_addr" {
  type        = string
  description = "Vault server URL for the public ingress."
}

// Generic additions
variable "vault_approle_roles" {
  type = map(
    object({
      token_policies = list(string)
    })
  )
  description = "Map of additional AppRole roles to configure for authentication in Vault."
  default     = {}
}

variable "vault_kv_mounts" {
  type = map(
    object({
      description = string
      version     = string
    })
  )
  description = "Map of additional key/value mountpoints to enable in Vault."
  default     = {}
}

variable "vault_policies" {
  type        = map(any)
  description = "Map of additional policies to create in Vault."
  default     = {}
}

// Authentication methods
variable "jwt_auth_backends" {
  type = map(object({
    description       = string
    jwks_url          = string
    bound_issuer      = string
    default_lease_ttl = optional(string, "1h")
    max_lease_ttl     = optional(string, "3h")
  }))
  description = "Map of JWT auth backends (for GitLab CI or others)."
  default     = {}
}

variable "gcp" {
  type = object({
    credentials       = optional(string)
    default_lease_ttl = optional(number, 3600)
    max_lease_ttl     = optional(number, 10800)
    projects = optional(map(object({
      impersonated_accounts = optional(map(object({
        service_account_id = optional(string)
        oauth_scopes       = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
      })), {})
      rolesets = optional(map(object({
        additional_bindings = optional(list(object({
          resource = string
          roles    = list(string)
        })), [])
        oauth_scopes = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
        roles        = list(string)
        type         = optional(string, "access_token")
      })), {})
      static_accounts = optional(map(object({
        additional_bindings = optional(list(object({
          resource = string
          roles    = list(string)
        })), [])
        service_account_id = optional(string)
        type               = optional(string, "access_token")
        oauth_scopes       = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
      })), {})
    })), {})
  })
  description = "GCP Secrets Engine configuration + static accounts, impersonated accounts and rolesets per project."
  default     = {}
}

variable "kubernetes_clusters" {
  type = map(object({
    config = object({
      host                = string
      ca_cert             = string
      service_account_jwt = optional(string)
      token_reviewer_jwt  = optional(string)
    })
    environment = string
    auth_roles = optional(map(object({
      namespaces             = list(string)
      service_accounts       = list(string)
      readonly_secret_paths  = optional(list(string), [])
      readwrite_secret_paths = optional(list(string), [])
      policies               = optional(list(string), [])
    })), {})
    secrets_roles = optional(map(object({
      allowed_kubernetes_namespaces = list(string)
      extra_annotations             = optional(map(string), {})
      extra_labels                  = optional(map(string), {})
      name_template                 = optional(string)
      role_name                     = optional(string)
      role_type                     = optional(string, "Role")
      role_rules = optional(list(object({
        apiGroups       = optional(list(string))
        nonResourceURLs = optional(list(string))
        resourceNames   = optional(list(string))
        resources       = optional(list(string))
        verbs           = optional(list(string))
      })), [])
      service_account_name = optional(string)
      token_default_ttl    = optional(number, 3600)
      token_max_ttl        = optional(number, 10800)
    })), {})
  }))
  description = "Map of Kubernetes clusters with their configuration, authentication roles and secrets roles."
  default     = {}
}

variable "okta_oidc" {
  type = object({
    client_id     = string
    client_secret = string
    discovery_url = string
  })
  sensitive   = true
  description = "Okta OIDC configuration."
}

variable "raft_snapshots_service_account" {
  type        = string
  description = "Service Account used by the raft-snapshot job to authenticate to Vault."
}

// RBAC
variable "admin_groups" {
  type        = list(string)
  description = "Okta groups allowed admin access to Vault."
  default     = []
}

variable "user_groups" {
  type        = list(string)
  description = "Okta groups allowed regular user access to Vault."
  default     = []
}

variable "admin_oidc_logging" {
  type        = bool
  description = "Log received OIDC tokens and claims from admin users when debug-level logging is active."
  default     = false
}

variable "user_oidc_logging" {
  type        = bool
  description = "Log received OIDC tokens and claims from non-admin users when debug-level logging is active."
  default     = false
}

variable "ci_secrets_policies" {
  type = map(object({
    admin = optional(object({ groups = list(string) }), { groups = [] })
    read  = optional(object({ groups = list(string) }), { groups = [] })
    list  = optional(object({ groups = list(string) }), { groups = [] })
  }))
  description = "Map of CI K/V secret paths with lists of Okta groups allowed to assume each admin|read|list role."
  default     = {}
}

variable "gcp_policies" {
  type = map(object({
    impersonated_accounts = optional(map(object({ groups = optional(list(string), []) })), {})
    rolesets              = optional(map(object({ groups = optional(list(string), []) })), {})
    static_accounts       = optional(map(object({ groups = optional(list(string), []) })), {})
  }))
  description = "Map of GCP projects and rolesets / service accounts with lists of Okta groups allowed to generate access tokens."
  default     = {}
}

variable "kubernetes_policies" {
  type = map(object({
    roles = optional(map(object({ groups = optional(list(string), []) })), {})
  }))
  description = "Map of Kubernetes clusters and roles with lists of Okta groups allowed to generate access tokens."
  default     = {}
}

variable "kubernetes_secrets_policies" {
  type = map(object({
    admin = optional(object({ groups = list(string) }), { groups = [] })
    read  = optional(object({ groups = list(string) }), { groups = [] })
    list  = optional(object({ groups = list(string) }), { groups = [] })
  }))
  description = "Map of Kubernetes K/V secret paths with lists of Okta groups allowed to assume each admin|read|list role."
  default     = {}
}

variable "shared_secrets_policies" {
  type = map(object({
    admin = optional(object({ groups = list(string) }), { groups = [] })
    read  = optional(object({ groups = list(string) }), { groups = [] })
    list  = optional(object({ groups = list(string) }), { groups = [] })
  }))
  description = "Map of shared K/V secret paths with lists of Okta groups allowed to assume each admin|read|list role."
  default     = {}
}

variable "chef_secrets_policies" {
  type = map(object({
    admin = optional(object({ groups = list(string) }), { groups = [] })
    read  = optional(object({ groups = list(string) }), { groups = [] })
    list  = optional(object({ groups = list(string) }), { groups = [] })
  }))
  description = "Map of Chef K/V secret paths with lists of Okta groups allowed to assume each admin|read|list role."
  default     = {}
}

variable "runway_secrets_policies" {
  type = map(object({
    admin = optional(object({ groups = list(string) }), { groups = [] })
    read  = optional(object({ groups = list(string) }), { groups = [] })
    list  = optional(object({ groups = list(string) }), { groups = [] })
  }))
  description = "Map of Runway K/V secret paths with lists of Okta groups allowed to assume each admin|read|list role."
  default     = {}
}

variable "ci_secrets_path_max_depth" {
  type        = number
  description = "Maximum depth for CI secret paths, used for created `.placeholder` secrets."
  default     = 10
}

// Chef Environment secrets
// https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/gcp_auth_backend_role#gce-only-parameters
variable "chef_environments" {
  /*
  db-benchmarking = {
    gcp_projects = ["gitlab-db-benchmarking"]
    roles = {
      patroni = {
        cookbooks           = ["gitlab-server", "gitlab-patroni"]
        gcp_instance_groups = ["patroni-db-bench-b", "patroni-db-bench-c"]
        gcp_zones           = ["us-east1-b", "us-east1-c", "us-east1-d"]
        gcp_labels          = ["key:value", ""]
        readonly_secret_paths = [
          "shared/env/db-benchmarking/foo/*",
          "shared/env/db-benchmarking/bar",
        ]
      }
    }
  }
  */
  type = map(object({
    gcp_projects = optional(list(string), [])
    roles = map(object({
      cookbooks             = optional(list(string), [])
      gcp_instance_groups   = optional(list(string), [])
      gcp_zones             = optional(list(string), [])
      gcp_labels            = optional(list(string), [])
      readonly_secret_paths = optional(list(string), [])
    }))
  }))
  description = "Map of Chef environments with roles."
  default     = {}
}
