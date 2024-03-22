# Learnings

## Questions

1. How to log, or is the logging, from a Cloud Function?
1. How to force a redeploy of a Cloud Function when the source changes in GCS?
1. How to deploy using revisions / without interrupting the service?

## Findings
### Terraform Google Cloud provider
- Apparently, the `google_eventarc_trigger` resource can't be used to create Eventarc triggers for Cloud Functions. Recently, its `destination.cloud_function` attribute was changed to be read-only, and its documentation now says:  _[WARNING] Creating Cloud Functions V2 triggers is only supported via the Cloud Functions product. An error will be returned if the user sets this value_. Instead, use the `google_cloudfunctions2_function` resource, `event_trigger` attribute.
