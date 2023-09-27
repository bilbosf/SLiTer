module "redis" {
  source  = "terraform-google-modules/memorystore/google"
  version = "7.1.2"

  name           = "packagecloud-redis"
  tier           = var.memorystore_tier
  memory_size_gb = var.memorystore_memory_size_gb

  project = var.gcp_project_id
  region  = var.gcp_region

  authorized_network = var.memorystore_authorized_network

  redis_version = var.memorystore_redis_version
  redis_configs = var.memorystore_redis_configs
}
