import os
import boto3
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

def posgreSQL_connection(): # postgreSQL 세션메이커 생성
    try:
        DB_URL = "postgresql://"+os.environ["POSTGRESQL_USERNAME"]+":"+os.environ["POSTGRESQL_PASSWORD"]+"@"+os.environ["POSTGRESQL_HOST_URL"]+"/"+os.environ["POSTGRESQL_DB_NAME"]
        engine = create_engine(DB_URL)
        postgreSQL = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        print("postgreSQL connected!")
        return postgreSQL
    except Exception as e:
        print("Error:",e)

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