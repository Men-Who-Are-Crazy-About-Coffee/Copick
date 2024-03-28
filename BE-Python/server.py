import os
import io
from io import BytesIO
import shutil
import uuid
from typing import List,Optional
from fastapi import FastAPI, File, UploadFile, Header, Form, Request, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv
from jose import JWTError
from sqlalchemy import text
import functions, s3_utils, DB_utils
from PIL import Image
from asyncio import TimeoutError, wait_for
from ultralytics import YOLO


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

s3_connection = s3_utils.s3_connection()
db_session_maker = DB_utils.posgreSQL_connection()
ai_model = YOLO('best.pt')

@app.get("/")
def read_root(): 
    return {"Hello": "World"}

@app.get("/api/python/test")
def test_api():
    return "test success"

@app.post("/api/python/analyze")
async def analyze_flaw(request: Request,
                        resultIndex: int = Form(...), file: UploadFile = File(...)):
        db_session = None
        try:
            authorization_header = request.headers.get('Authorization')
            access_token = authorization_header[7:]

            await functions.check_token(access_token)
            # member_index = payload["userIndex"]

            result_index = str(resultIndex)
            
            image_byte_stream,result_normal,result_flaw,cropped_images = await functions.manufacture_image(file)
            file_name = str(uuid.uuid4())+".jpg"
            s3_path = os.environ["AWS_S3_URL"]+"/result/"+result_index+"/sequence/"+file_name

            db_session = db_session_maker()
            DB_utils.posgreSQL_save_sequence(result_index,file_name,result_normal,result_flaw,db_session)
                    
            s3_utils.s3_save_sequence(result_index,image_byte_stream,file_name,s3_connection)

            for cropped_image in cropped_images:
                cropped_file_name = str(uuid.uuid4())+".jpg"
                DB_utils.posgreSQL_save_flaw(result_index,cropped_file_name,db_session)
                s3_utils.s3_save_flaw(result_index,cropped_image,cropped_file_name,s3_connection)

            db_session.commit()
            return s3_path
        except JWTError as e:
            return"Invalid token"
        except TypeError as e:
            print("Error:",e)
            return "No header attribute"
        except Exception as e:
            print("Error:",e)
            return "error"
        finally:
            if db_session:
                db_session.close()

@app.get("/api/python/roasting")
async def analyze_roasting(image_link:str):
    try:
        roatsing_type = await functions.extract_roasting(image_link)
        return roatsing_type
    except Exception as e:
            print("Error:",e)
            return "error"
    
@app.get("/api/python/video")
def streaming():
    return StreamingResponse(functions.get_stream_video(), media_type="multipart/x-mixed-replace; boundary=frame")

@app.websocket("/ws/python/video")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            try:
                # 5초 동안 데이터를 기다립니다.
                frame_data = await wait_for(websocket.receive_bytes(), timeout=5)

                await websocket.send_bytes(functions.manufacture_video(frame_data,ai_model))
                # await websocket.send_bytes(frame_data)
            except TimeoutError:
                # 5초 동안 데이터가 수신되지 않으면 루프를 종료합니다.
                break
    except WebSocketDisconnect:
        # 클라이언트 연결이 끊어진 경우 처리
        print("Client disconnected.")
    except Exception as e:
        print("Error:",e)
        return "error"
    finally:
        # 연결을 닫습니다.
        await websocket.close()