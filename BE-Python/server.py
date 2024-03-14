import os
import shutil
import utils
from typing import Union,List,Optional
from fastapi import FastAPI, File, UploadFile, Header
from dotenv import load_dotenv
from jose import jwt,JWTError
from sqlalchemy import text

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

app = FastAPI()
s3 = utils.s3_connection()
db_session_maker = utils.posgreSQL_connection()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/jwt/{token}")
def valid_token(token: str):
    try:
        payload = jwt.decode(token,os.environ["JWT_SECRET_KEY"],algorithms=["HS512"])
        return {"token": payload}
    except JWTError:
        return {"error"}

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

@app.post("/header")
async def read_items(x_token: Optional[List[str]] = Header(None),y_token: Optional[List[str]] = Header(None)):
    try:
        return {"X-Token values": x_token + y_token}
    except Exception as e:
        print(e)
        return {"error"}
