module "mysql" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "16.1.0"

  name                 = "packagecloud"
  random_instance_name = true

  user_name = "admin"

  db_name      = "packages_onpremise"
  db_charset   = "utf8mb4"
  db_collation = "utf8mb4_general_ci"
  disk_size    = var.cloudsql_disk_size

  availability_type = var.cloudsql_availability_type
  region            = var.gcp_region
  zone              = var.cloudsql_zone_master_instance
  project_id        = var.gcp_project_id

  database_version            = var.cloudsql_database_version
  tier                        = var.cloudsql_tier
  deletion_protection_enabled = var.cloudsql_deletion_protection_enabled

  ip_configuration = var.cloudsql_ip_configuration

  maintenance_window_day          = 7
  maintenance_window_hour         = 0
  maintenance_window_update_track = "stable"

  backup_configuration = var.cloudsql_backup_configuration

  database_flags = var.cloudsql_database_flags

  insights_config = var.cloudsql_insights_config
}

module "sql-proxy-workload-identity" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version = "28.0.0"

  project_id  = var.gcp_project_id
  name        = "packagecloud-sql-proxy"
  namespace   = "packagecloud"
  k8s_sa_name = "packagecloud-sql-proxy"

  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
}

resource "google_project_iam_member" "wi-cloudsql" {
  project = var.gcp_project_id

  role   = "roles/cloudsql.client"
  member = "serviceAccount:${module.sql-proxy-workload-identity.gcp_service_account_email}"

  condition {
    title      = "Cloud SQL access to the packagecloud instance"
    expression = "resource.name.startsWith(\"projects/${var.gcp_project_id}/instances/packagecloud\")"
  }
}
