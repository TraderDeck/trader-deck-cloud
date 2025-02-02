import os
import requests
import boto3
import csv
import io

s3 = boto3.client("s3")
S3_BUCKET_ICONS = "td-ticker-icons"
S3_BUCKET_MISC = "td-misc"
list_tickers_filename = "list_tickers_nasdaq.csv"     # Change to your actual file path in S3
market_cap_cap = 1_000_000_000

def parse_market_cap(market_cap):
    try:
        return int(market_cap.replace(',', ''))
    except ValueError:
        return 0  

def lambda_handler(event, context):
    try:
        response = s3.get_object(Bucket=S3_BUCKET_MISC, Key=list_tickers_filename)

        # Read CSV content
        csv_content = response["Body"].read().decode("utf-8")
        csv_reader = csv.DictReader(io.StringIO(csv_content))

        filtered_tickers = [
            row["Symbol"] for row in csv_reader
            if row.get("Market Cap") and parse_market_cap(row["Market Cap"]) > market_cap_cap
        ]


    except Exception as e:
        print(f"Error processing CSV from S3: {e}")
        return {
            "statusCode": 500,
            "error": str(e)
        }
    
    base_url = "https://assets.parqet.com/logos/symbol/{}?format=svg&size=300"
    
    save_dir = "/tmp/stock_icons"
    os.makedirs(save_dir, exist_ok=True)

    print("list of tickers filtered is: ", filtered_tickers)

    for stock in filtered_tickers:
        url = base_url.format(stock)
        image_path = os.path.join(save_dir, f"{stock}.svg")

        try:
            response = requests.get(url, stream=True)
            response.raise_for_status()  
            
            with open(image_path, "wb") as file:
                for chunk in response.iter_content(1024):
                    file.write(chunk)
            
            print(f"Downloaded: {stock} -> {image_path}")

            s3.upload_file(image_path, S3_BUCKET_ICONS, f"{stock}.svg")
            print(f"Uploaded {stock}.svg to S3 bucket {S3_BUCKET_ICONS}")

        except requests.exceptions.RequestException as e:
            print(f"Failed to download {stock}: {e}")
        except boto3.exceptions.S3UploadFailedError as e:
            print(f"Failed to upload {stock} to S3: {e}")

    return {"statusCode": 200, "body": "Stock icons downloaded and uploaded to S3"}