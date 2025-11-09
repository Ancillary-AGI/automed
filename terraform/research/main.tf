terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
resource "google_compute_network" "research_vpc" {
  name                    = "automed-research-vpc"
  auto_create_subnetworks = false
  description             = "VPC for AutoMed Research Platform"
}

# Subnets
resource "google_compute_subnetwork" "research_subnet" {
  name          = "automed-research-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.research_vpc.id

  secondary_ip_range {
    range_name    = "research-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "research-services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# GKE Cluster
resource "google_container_cluster" "research_cluster" {
  name     = "automed-research-cluster"
  location = var.region

  network    = google_compute_network.research_vpc.id
  subnetwork = google_compute_subnetwork.research_subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "research-pods"
    services_secondary_range_name = "research-services"
  }

  # Enable Autopilot for simplified management
  enable_autopilot = true

  # GPU support
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.research_sa.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }

  # Enable workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enable shielded nodes
  enable_shielded_nodes = true

  # Network policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # Binary authorization
  enable_binary_authorization = true

  # Private cluster
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.allowed_ip_ranges
      display_name = "Allowed Research IPs"
    }
  }
}

# GPU Node Pool
resource "google_container_node_pool" "gpu_pool" {
  name       = "gpu-pool"
  cluster    = google_container_cluster.research_cluster.id
  node_count = 1

  node_config {
    machine_type = "n1-standard-8"

    # GPU configuration
    guest_accelerator {
      type  = "nvidia-tesla-v100"
      count = 2
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Enable GPU driver installation
    linux_node_config {
      sysctls = {
        "net.core.somaxconn" = "1024"
      }
    }
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Cloud Storage Buckets
resource "google_storage_bucket" "research_data" {
  name          = "${var.project_id}-research-data"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 1095 # 3 years
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "research_models" {
  name          = "${var.project_id}-research-models"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# Cloud SQL PostgreSQL
resource "google_sql_database_instance" "research_db" {
  name             = "automed-research-db"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-custom-8-32768" # 8 vCPUs, 32GB RAM

    disk_size = 500
    disk_type = "PD_SSD"

    backup_configuration {
      enabled    = true
      start_time = "02:00"
    }

    maintenance_window {
      day  = 7
      hour = 3
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.research_vpc.id
    }
  }

  deletion_protection = true
}

resource "google_sql_database" "research_database" {
  name     = "researchdb"
  instance = google_sql_database_instance.research_db.name
}

resource "google_sql_user" "research_user" {
  name     = "research"
  instance = google_sql_database_instance.research_db.name
  password = var.db_password
}

# Memorystore Redis
resource "google_redis_instance" "research_cache" {
  name           = "automed-research-cache"
  tier           = "STANDARD_HA"
  memory_size_gb = 16
  region         = var.region

  redis_version = "REDIS_6_X"
  display_name  = "AutoMed Research Cache"

  auth_enabled = true

  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 3
        minutes = 0
      }
    }
  }
}

# Cloud Pub/Sub for event streaming
resource "google_pubsub_topic" "research_events" {
  name = "automed-research-events"

  message_retention_duration = "604800s" # 7 days
}

resource "google_pubsub_subscription" "research_events_sub" {
  name  = "automed-research-events-sub"
  topic = google_pubsub_topic.research_events.name

  ack_deadline_seconds = 60

  expiration_policy {
    ttl = "300000.5s" # 3.5 days
  }
}

# Vertex AI for advanced ML
resource "google_vertex_ai_featurestore" "research_features" {
  name   = "automed-research-features"
  region = var.region

  online_serving_config {
    fixed_node_count = 3
  }

  encryption_spec {
    kms_key_name = google_kms_crypto_key.research_key.id
  }
}

# Cloud Build for CI/CD
resource "google_cloudbuild_trigger" "research_build" {
  name = "automed-research-build"

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "gcr.io/${var.project_id}/research-service:$COMMIT_SHA", "."]
      dir  = "backend/research-service"
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/${var.project_id}/research-service:$COMMIT_SHA"]
    }

    step {
      name = "gcr.io/cloud-builders/gke-deploy"
      args = [
        "run",
        "--filename=helm/automed-research",
        "--location=${var.region}",
        "--cluster=automed-research-cluster"
      ]
    }
  }
}

# Service Account
resource "google_service_account" "research_sa" {
  account_id   = "automed-research-sa"
  display_name = "AutoMed Research Service Account"
}

# IAM bindings
resource "google_project_iam_member" "research_sa_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.research_sa.email}"
}

resource "google_project_iam_member" "research_sa_ai" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.research_sa.email}"
}

resource "google_project_iam_member" "research_sa_compute" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.research_sa.email}"
}

# KMS for encryption
resource "google_kms_key_ring" "research_keyring" {
  name     = "automed-research-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "research_key" {
  name     = "research-encryption-key"
  key_ring = google_kms_key_ring.research_keyring.id

  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

# Monitoring and Logging
resource "google_monitoring_dashboard" "research_dashboard" {
  dashboard_json = file("${path.module}/dashboard.json")
}

# Load Balancer
resource "google_compute_global_address" "research_ip" {
  name = "automed-research-ip"
}

resource "google_compute_backend_service" "research_backend" {
  name        = "automed-research-backend"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_container_cluster.research_cluster.endpoint
  }
}

resource "google_compute_url_map" "research_urlmap" {
  name            = "automed-research-urlmap"
  default_service = google_compute_backend_service.research_backend.id
}

resource "google_compute_target_http_proxy" "research_proxy" {
  name    = "automed-research-proxy"
  url_map = google_compute_url_map.research_urlmap.id
}

resource "google_compute_global_forwarding_rule" "research_forwarding" {
  name       = "automed-research-forwarding"
  target     = google_compute_target_http_proxy.research_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.research_ip.address
}

# SSL Certificate
resource "google_compute_managed_ssl_certificate" "research_cert" {
  name = "automed-research-cert"

  managed {
    domains = ["research.automed.ai"]
  }
}

# Outputs
output "cluster_name" {
  value = google_container_cluster.research_cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.research_cluster.endpoint
}

output "research_ip" {
  value = google_compute_global_address.research_ip.address
}

output "database_connection" {
  value = google_sql_database_instance.research_db.connection_name
}

output "redis_host" {
  value = google_redis_instance.research_cache.host
}