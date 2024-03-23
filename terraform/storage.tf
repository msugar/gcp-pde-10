# Cloud Storage bucket names must be globally unique
resource "random_id" "bucket_name_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "drop_zone" {
  name          = "drop-zone-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

# Grant the pubsub.publisher role to the Cloud Storage service agent
resource "google_project_iam_member" "gcs_pubsub_publishing" {
  project = data.google_project.project.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
}

output "cloud_storage_service_agent_email" {
  value = data.google_storage_project_service_account.gcs_sa.email_address
}

resource "google_storage_bucket" "raw_zone" {
  name          = "raw-zone-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket" "refined_zone" {
  name          = "refined-zone-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket" "curated_zone" {
  name          = "curated-zone-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket" "resources" {
  name          = "resources-${data.google_project.project.name}-${random_id.bucket_name_suffix.hex}"
  location      = var.region
  force_destroy = true
}

