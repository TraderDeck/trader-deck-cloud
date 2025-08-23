import os
import json
import boto3
import re

# Fetch environment variables
BUCKET_NAME = os.getenv("BUCKET_NAME", "default-bucket")
METADATA_FILE_PATH = os.getenv("METADATA_FILE_PATH", "metadata/info.json")

s3 = boto3.client("s3")

def list_all_objects(bucket_name):
    """ Retrieve all objects from S3 using pagination """
    tickers = set()
    paginator = s3.get_paginator("list_objects_v2")
    
    for page in paginator.paginate(Bucket=bucket_name):
        if "Contents" in page:
            for obj in page["Contents"]:
                key = obj["Key"]
                match = re.match(r"^([A-Za-z0-9_-]+)\.png$", key)  # Match <symbol>.png files in root
                if match:
                    tickers.add(match.group(1))
    
    return sorted(list(tickers))

def lambda_handler(event, context):
    try:
        # Get all tickers
        tickers = list_all_objects(BUCKET_NAME)

        # Prepare JSON data
        metadata = {"available_tickers": tickers}

        # Upload to S3
        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=METADATA_FILE_PATH,
            Body=json.dumps(metadata, indent=4),
            ContentType="application/json"
        )

        return {"statusCode": 200, "body": f"Metadata updated: {len(tickers)} tickers found."}

    except Exception as e:
        return {"statusCode": 500, "body": f"Error: {str(e)}"}