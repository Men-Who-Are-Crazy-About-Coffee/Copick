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

def s3_save_sequence(result_index,image_byte_stream,file_name ,s3_connection):
    try:
        file_path = "result/"+result_index+"/sequence/"+file_name
        s3_connection.upload_fileobj(image_byte_stream,os.environ["AWS_S3_BUCKET"],file_path)
    except Exception as e:
        print("Error(s3_save_sequence):",e)

def s3_save_flaw(result_index,image_byte_stream,file_name ,s3_connection):
    try:
        file_path = "result/"+result_index+"/flaw/"+file_name
        s3_connection.upload_fileobj(image_byte_stream,os.environ["AWS_S3_BUCKET"],file_path)
    except Exception as e:
        print("Error(s3_save_flaw):",e)