import os
import shutil
import uuid
from typing import List,Optional
from fastapi import FastAPI, File, UploadFile, Header
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from jose import JWTError
from sqlalchemy import text
import functions, s3_utils, DB_utils
from PIL import Image

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True, # cookie 포함 여부를 설정한다. 기본은 False
    allow_methods=["*"],    # 허용할 method를 설정할 수 있으며, 기본값은 'GET'이다.
    allow_headers=["*"],	# 허용할 http header 목록을 설정할 수 있으며 Content-Type, Accept, Accept-Language, Content-Language은 항상 허용된다.
)

s3 = s3_utils.s3_connection()
db_session_maker = DB_utils.posgreSQL_connection()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("api/test")
def test_api():
    return {"test success"}

@app.post("/image")
async def upload_image(file: UploadFile = File(...)):
    try:
        DIR = "./image"
        if not os.path.exists(DIR): # 해당 디렉토리가 없다면 생성
            os.makedirs(DIR) 
        filename = "test2.png"
        with open(os.path.join(DIR, filename), "wb") as buffer:
            shutil.copyfileobj(file.file,buffer)
        return {filename}
    except:
        return {"error"}
    
@app.post("/s3")
async def upload_image(files: List[UploadFile] = File(...)):   
    try:
        results = []
        for file in files:
            s3.upload_fileobj(file.file,os.environ["AWS_S3_BUCKET"],file.filename)
            results.append("{file.filename} upload success")
        return {results}
    except Exception as e:
        print(e)
        return {"error"}
    
@app.get("/DB")
async def first_get():
    try:
        try:
            print("income")
            db_sesson = db_session_maker()
            response = db_sesson.execute(text("SELECT * FROM member")).fetchall()
            print(type(response))
            print(response)
            print(response[0][0])
            return response[0][0]
        finally:
            db_sesson.close()
    except Exception as e:
        print(e)
        return {"error"}
    
@app.post("/api/analyze")
async def analyze_image(accessToken: Optional[List[str]] = Header(None),resultIndex: Optional[List[str]] = Header(None)
                        ,file: UploadFile = File(...)):
        db_session = None
        try:
            # payload = await functions.check_token(accessToken[0])
            # member_index = payload["userIndex"]

            result_index = resultIndex[0]
            
            image_byte_stream,result_normal,result_flaw = await functions.manufacture_image(file)
            file_name = str(uuid.uuid4())+".jpg"
            file_path = "result/"+result_index+"/"+file_name

            print(file_path)

            db_session = db_session_maker()
            db_session.execute(text("INSERT INTO sequence(result_index,sequence_image,result_normal,result_flaw) VALUES(%s,\'%s\',%d,%d)"
                %(result_index,os.environ["AWS_S3_URL"]+"/"+file_path,result_normal,result_flaw)))
                    
            s3.upload_fileobj(image_byte_stream,os.environ["AWS_S3_BUCKET"],file_path)

            db_session.commit()
            return image_byte_stream
        except JWTError:
            return("Invalid token")
        except TypeError:
            return("No header attribute") 
        except Exception as e:
            print("Error:",e)
            return {"error"}
        finally:
            if db_session:
                db_session.close()