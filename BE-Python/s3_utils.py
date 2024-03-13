import os
import boto3

def s3_connection():    # s3 클라이언트 생성
    try:
        s3 = boto3.client(
            service_name="s3",
            region_name="ap-northeast-2",
            aws_access_key_id=os.environ["AWS_ACCESS_KEY"],
            aws_secret_access_key=os.environ["AWS_SECRET_KEY"],
        )
        print("s3 bucket connected!") 
        return s3
    except Exception as e:
        print("Error:",e)