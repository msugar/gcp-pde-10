resource "google_service_account" "eventarc_trigger_sa" {
  account_id   = "eventarc-trigger-sa"
  display_name = "Eventarc Trigger Service Account"
  project      = var.project_id
}

locals {
  eventarc_trigger_sa_roles = [
    "roles/eventarc.eventReceiver",
    "roles/cloudfunctions.invoker",
    "roles/run.invoker",
  ]
}

resource "google_project_iam_member" "eventarc_trigger_sa_iam" {
  for_each = toset(local.eventarc_trigger_sa_roles)

  project = var.project_id
  role    = each.key
  member  = google_service_account.eventarc_trigger_sa.member

  depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}

resource "google_service_account" "store_file_attributes_sa" {
  account_id   = "store-file-attributes-sa"
  display_name = "Service Account for store_file_attributes Cloud Function"
  project      = var.project_id
}

locals {
  store_file_attributes_sa_roles = [
    "roles/artifactregistry.reader",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/cloudfunctions.developer",
    "roles/eventarc.eventReceiver",
    "roles/iam.serviceAccountUser",
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
  ]
}

resource "google_project_iam_member" "store_file_attributes_sa_iam" {
  for_each = toset(local.store_file_attributes_sa_roles)

  project = var.project_id
  role    = each.key
  member  = google_service_account.store_file_attributes_sa.member

  depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}

resource "google_cloudfunctions2_function" "store_file_attributes" {
  depends_on = [
    google_project_service.apis["cloudfunctions.googleapis.com"],
    google_project_iam_member.eventarc_trigger_sa_iam,
    google_project_iam_member.store_file_attributes_sa_iam,
  ]

  name        = "store-file-attributes"
  description = "Collects attributes of a file uploaded to the drop zone GCS bucket and saves them into BigQuery."
  location    = var.region

  build_config {
    runtime     = "python310"
    entry_point = "store_file_attributes"
    source {
      storage_source {
        bucket = google_storage_bucket_object.store_file_attributes_zip.bucket
        object = google_storage_bucket_object.store_file_attributes_zip.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256Mi"
    timeout_seconds    = 120
    environment_variables = {
      SINK_BQ_PROJECT = google_bigquery_table.stored_file_attributes.project
      SINK_BQ_DATASET = google_bigquery_table.stored_file_attributes.dataset_id
      SINK_BQ_TABLE   = google_bigquery_table.stored_file_attributes.table_id
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.store_file_attributes_sa.email
  }

  event_trigger {
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.eventarc_trigger_sa.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.drop_zone.name
    }
  }
}

/*
# Create an Eventarc trigger, routing Cloud Storage events to Cloud Functions
resource "google_eventarc_trigger" "drop_zone_storage_object_finalized" {
  name     = "drop-zone-storage-object-finalized"
  location = google_cloudfunctions2_function.store_file_attributes.location

  # Capture objects changed in the bucket
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.drop_zone.name
  }

  # Send events to Cloud Function
  destination {
    cloud_function = google_cloudfunctions2_function.store_file_attributes.id
  }

  service_account = google_service_account.eventarc_trigger_sa.email

  depends_on = [
    google_project_service.apis["eventarc.googleapis.com"],
    google_project_iam_member.eventarc_trigger_sa_iam
  ]
}
*/
