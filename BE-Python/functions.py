import io
import os
import shutil
from PIL import Image
from fastapi import File, UploadFile;
from jose import jwt,JWTError

async def check_token(token: str):
    try:
        payload = jwt.decode(token,os.environ["JWT_SECRET_KEY"],algorithms=["HS512"])
        return payload
    except JWTError:
        raise JWTError("Invalid token")

async def manufacture_image(file: UploadFile = File(...)):
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data))
    image = image.resize((300, 280)) 

    #flaw 생성됨

    # 바이트 스트림으로 이미지 저장
    img_byte_arr = io.BytesIO()
    image.save(img_byte_arr, format='JPEG')
    await file.close()
    # 바이트 스트림을 반환
    img_byte_arr.seek(0)  # Seek to the start of the stream
    return img_byte_arr,10,20