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
    image.save("./image/test.png",format='PNG')
    await file.close()