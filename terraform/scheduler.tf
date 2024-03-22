/*resource "google_cloud_scheduler_job" "orchestration_job" {
  name     = "orchestration-job"
  region   = var.region
  schedule = "0 * * * *"

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/workflows/orchestration/executions"
  }
}
*/

resource "google_service_account" "scheduler_sa" {
  account_id   = "scheduler-sa"
  display_name = "Scheduler Service Account"
  project      = var.project_id
}

locals {
  scheduler_sa_roles = [
    "roles/workflows.invoker",
  ]
}

resource "google_project_iam_member" "scheduler_sa" {
  for_each = toset(local.scheduler_sa_roles)

  project = var.project_id
  role    = each.key
  member  = google_service_account.scheduler_sa.member

  depends_on = [
    google_project_service.apis["workflows.googleapis.com"],
  ]
}
