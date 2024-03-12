import os
import shutil
from typing import Union
from fastapi import FastAPI, File, UploadFile
from dotenv import load_dotenv
from jose import jwt,JWTError

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/jwt/{token}")
def valid_token(token: str):
    try:
        payload = jwt.decode(token,os.environ["SECRET_KEY"],algorithms=["HS512"])
    except JWTError:
        return {"error"}
    return {"token": payload}

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