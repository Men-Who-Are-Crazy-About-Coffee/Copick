import os
import shutil
import uuid
from typing import List,Optional
from fastapi import FastAPI, File, UploadFile, Header, Form, Request
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

@app.get("/api/python/test")
def test_api():
    return "test success"

@app.post("/api/python/analyze")
async def analyze_flaw(request: Request,
                        resultIndex: str = Form(...), file: UploadFile = File(...)):
        db_session = None
        try:
            authorization_header = request.headers.get('Authorization')
            access_token = authorization_header[7:]

            payload = await functions.check_token(access_token)
            # member_index = payload["userIndex"]

            result_index = resultIndex[0]
            
            image_byte_stream,result_normal,result_flaw = await functions.manufacture_image(file)
            file_name = str(uuid.uuid4())+".jpg"
            file_path = "result/"+result_index+"/"+file_name

            db_session = db_session_maker()
            db_session.execute(text("INSERT INTO sequence(result_index,sequence_image,result_normal,result_flaw) VALUES(%s,\'%s\',%d,%d)"
                %(result_index,os.environ["AWS_S3_URL"]+"/"+file_path,result_normal,result_flaw)))
                    
            s3.upload_fileobj(image_byte_stream,os.environ["AWS_S3_BUCKET"],file_path)

            db_session.commit()
            return image_byte_stream
        except JWTError:
            return"Invalid token"
        except TypeError:
            return "No header attribute"
        except Exception as e:
            print("Error:",e)
            return "error"
        finally:
            if db_session:
                db_session.close()

@app.post("/api/python/roasting")
async def analyze_roasting(resultIndex: str = Form(...), file: UploadFile = File(...)):
    try:
        roatsing_type = await functions.extract_roasting(file)
        return roatsing_type
    except Exception as e:
            print("Error:",e)
            return "error"