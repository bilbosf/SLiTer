variable "environment" {
  description = "Environment for the packagecloud:enterprise installation."
  type        = string
}

variable "gcp_region" {
  description = "The region of the GCP resources."
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID to manage the GCP resources."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name that contains the DEB/RPM/etc packages."
  type        = string
}

variable "bucket_versioning_enabled" {
  description = "Boolean to control if object versioning should be enabled."
  type        = bool
  default     = true
}

variable "bucket_replication" {
  description = "S3 replication bucket settings."
  type = object({
    name          = optional(string, "")
    storage_class = optional(string, "STANDARD_IA")
  })
  default = {}
}

variable "aws_tags" {
  description = "A mapping of tags to assign to all AWS resources."
  type        = map(string)
  default     = {}
}

variable "cloudflare_zone_id" {
  description = "Optional (when creating Cloudflare DNS record): Cloudflare zone ID."
  type        = string
  default     = ""
}

variable "cloudflare_dns_record_name" {
  description = "Optional (when creating Cloudflare DNS record): DNS record name -- eg. packages"
  type        = string
  default     = ""
}

variable "cloudflare_dns_record_value" {
  description = "Optional (when creating Cloudflare DNS record): IP address the DNS record should point to."
  type        = string
  default     = ""
}

variable "cloudsql_disk_size" {
  description = "Disk size for the DB."
  type        = number
  default     = 50
}

variable "cloudsql_availability_type" {
  description = "The availability type for the master instance."
  type        = string
  default     = "REGIONAL"
}

variable "cloudsql_zone_master_instance" {
  description = "The zone for the master instance, it should be something like: `us-central1-a`, `us-east1-c`."
  type        = string
}

variable "cloudsql_database_version" {
  description = "The database version to use."
  type        = string
}

variable "cloudsql_tier" {
  description = "The tier for the master instance."
  type        = string
}

variable "cloudsql_deletion_protection_enabled" {
  description = "Enables protection of an instance from accidental deletion across all surfaces (API, gcloud, Cloud Console and Terraform)."
  type        = bool
  default     = true
}

variable "cloudsql_ip_configuration" {
  description = "The ip_configuration settings subblock"
  type = object({
    authorized_networks                           = list(map(string))
    ipv4_enabled                                  = bool
    private_network                               = string
    require_ssl                                   = bool
    allocated_ip_range                            = string
    enable_private_path_for_google_cloud_services = optional(bool)
  })
}

variable "cloudsql_backup_configuration" {
  description = "The backup_configuration settings subblock for the database setings"
  type = object({
    binary_log_enabled             = optional(bool, false)
    enabled                        = optional(bool, false)
    start_time                     = optional(string)
    location                       = optional(string)
    transaction_log_retention_days = optional(string)
    retained_backups               = optional(number)
    retention_unit                 = optional(string)
  })
  default = {}
}

variable "cloudsql_database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server. See [more details](https://cloud.google.com/sql/docs/mysql/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "sql_mode",
      value = "STRICT_ALL_TABLES,NO_AUTO_VALUE_ON_ZERO"
    }
  ]
}

variable "cloudsql_insights_config" {
  description = "The insights_config settings for the database."
  type = object({
    query_plans_per_minute  = number
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
  })
  default = null
}

variable "memorystore_tier" {
  description = "The service tier of the instance. https://cloud.google.com/memorystore/docs/redis/reference/rest/v1/projects.locations.instances#Tier"
  type        = string
}

variable "memorystore_memory_size_gb" {
  description = "Redis memory size in GiB"
  type        = number
}

variable "memorystore_authorized_network" {
  description = "The full name of the Google Compute Engine network to which the instance is connected."
  type        = string
  default     = null
}

variable "memorystore_redis_version" {
  description = "The version of Redis software."
  type        = string
}

variable "memorystore_redis_configs" {
  description = "The Redis configuration parameters. See [more details](https://cloud.google.com/memorystore/docs/redis/reference/rest/v1/projects.locations.instances#Instance.FIELDS.redis_configs)"
  type        = map(any)
  default     = {}
}
