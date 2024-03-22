import os

from typing import Dict
from cloudevents.http import CloudEvent

import functions_framework
from google.cloud import bigquery

@functions_framework.cloud_event
def store_file_attributes(cloud_event: CloudEvent):
    """Collects attributes of a file uploaded to the drop zone GCS bucket and saves them into BigQuery.
    
    This function is triggered by a change in a storage bucket.

    Args:
        cloud_event: The CloudEvent that triggered this function.
    """
    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    data: Dict = cloud_event.data
    bucket = data["bucket"]
    name = data["name"]
    size = data["size"]
    #metageneration = data["metageneration"]
    time_created = data["timeCreated"]
    #updated = data["updated"]
    #md5_hash = data["md5_hash"]

    print(f"File attributes: event_id: {event_id}, event_type: {event_type}, bucket: {bucket}, name: {name}, time_created: {time_created}")

    sink_bq_project = os.environ['SINK_BQ_PROJECT']
    sink_bq_dataset = os.environ['SINK_BQ_DATASET']
    sink_bq_table   = os.environ['SINK_BQ_TABLE']
    table_id = f"{sink_bq_project}.{sink_bq_dataset}.{sink_bq_table}"

    rows_to_insert = [
        {u"bucket": bucket, u"name": name, u"size": size, u"time_created": time_created, u"status": u"dropped"}
    ]

    # Construct a BigQuery client object.
    client = bigquery.Client()
    
    errors = client.insert_rows_json(table_id, rows_to_insert)  # Make an API request.
    if errors == []:
        print("File attributes stored")
    else:
        print("Encountered errors while storing file attributes: {}".format(errors))

