variable "project_id" {
  description = "The ID of the Google Cloud project"
}

variable "region" {
  description = "The Google Cloud Region where resources will be created"
}

variable "workflow_dataset" {
  description = "The name of the workflow dataset in BigQuery"
  default     = "workflow"
}

variable "pipeline_dataset" {
  description = "The name of the pipeline dataset in BigQuery"
  default     = "pipeline"
}
