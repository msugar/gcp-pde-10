# Learnings

## Questions

1. How to log from a Cloud Function to Cloud Logging?
1. How to deploy using revisions and/or without interrupting the service?

## Findings

### Terraform Google Cloud provider

#### How to create Eventarc triggers for Cloud Functions

Use the `google_cloudfunctions2_function` resource, `event_trigger` attribute.

Apparently, the `google_eventarc_trigger` resource can't be used to create Eventarc triggers for Cloud Functions. Recently, its `destination.cloud_function` attribute was changed to be read-only, and its documentation now says:  _[WARNING] Creating Cloud Functions V2 triggers is only supported via the Cloud Functions product. An error will be returned if the user sets this value_. 

#### How to force a redeploy of a Cloud Function when its source changes?
1. `data "archive_file"` to zip the directory with the Cloud Function's code and resources (like `requirements.txt`)
1. `resource "google_storage_bucket"` to create a bucket to store the zip file
1. `resource "google_storage_bucket_object"` to store the zip file in the bucket
1. But steps 1 to 3 are not enough, you still need a way to force the re-deployment when the source code changes. To achieve that, use [`replace_triggered_by`](https://www.terraform.io/language/meta-arguments/lifecycle#replace_triggered_by) as a workaround, as suggested by [BluetriX](https://github.com/hashicorp/terraform-provider-google/issues/1938#issuecomment-1229042663) in [Updating Cloud Functions' source code requires changing zip path](https://github.com/hashicorp/terraform-provider-google/issues/1938).