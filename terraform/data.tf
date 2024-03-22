# Used to retrieve project information later
data "google_project" "project" {}

# The Google Cloud Storage service agent
data "google_storage_project_service_account" "gcs_sa" {}
