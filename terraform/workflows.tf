# Grant the roles/logging.logWriter role to the default service account associated with the workflow
resource "google_project_iam_member" "worfklows_log_writing" {
  project = data.google_project.project.id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}