import io
import os
import shutil
from PIL import Image
from fastapi import File, UploadFile;
from jose import jwt,JWTError
import cv2
import numpy as np
from matplotlib import pyplot as plt
import extcolors

async def check_token(token: str):
    try:
        payload = jwt.decode(token,os.environ["JWT_SECRET_KEY"],algorithms=["HS512"])
        return payload
    except JWTError:
        raise JWTError("Invalid token")

async def extract_roasting(file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        image = image.convert("RGB") #for safe
        colors,pixel_count = extcolors.extract_from_image(image) 
        biggest = 0 
        r_gap=0 
        g_gap=0 
        b_gap=0 
        for c in colors: 
            RGB_sum = c[0][0]+c[0][1]+c[0][2] 
            if(RGB_sum>=600&RGB_sum>biggest): 
                biggest=RGB_sum 
                r_gap=255-c[0][0] 
                g_gap=255-c[0][1] 
                b_gap=255-c[0][2] 
        print(pixel_count) 
        print(r_gap,g_gap,b_gap)
        for c in colors:
            # 색상에 gap 값을 더합니다.
            adjusted_color = (
                max(0, min(255, c[0][0] + r_gap)),
                max(0, min(255, c[0][1] + g_gap)),
                max(0, min(255, c[0][2] + b_gap))
            )
            # 수정된 색상을 classify_roasting 함수에 전달합니다.
            roasting_type = await classify_roasting(adjusted_color)
            print(roasting_type)
            if(1<=roasting_type<=8):
                return roasting_type
        return "No matching roasting stage found"
    except Exception as e:
        print("Error:",e)

async def classify_roasting(rgb_color):
    # HEX 색상을 RGB로 변환하는 함수
    def hex_to_rgb(hex_color):
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    # RGB 색상의 각 채널 간 차이의 절대값 합을 계산
    def calculate_color_difference(rgb_color):
        return abs(rgb_color[0] - rgb_color[1]) + abs(rgb_color[1] - rgb_color[2]) + abs(rgb_color[2] - rgb_color[0])
    # def calculate_color_difference(rgb_color):
    #     return sum(rgb_color)
    
    color_difference = calculate_color_difference(rgb_color)
    # 각 경계값의 밝기 계산
    boundaries_hex = ['896234','845c2f', '7f542c', '784d2b', '673f28', '512e22', '402821', '332723', '2D2421']
    boundaries_difference = [calculate_color_difference(hex_to_rgb(boundary)) for boundary in boundaries_hex]
    
    for i, boundary_difference in enumerate(boundaries_difference):
        if color_difference >= boundary_difference:
            # return f"Roasting Stage {i}"
            return i
    # return f"Roasting Stage {len(boundaries_difference)}"
    return len(boundaries_difference)

async def manufacture_image(file: UploadFile = File(...)):
    try:
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        image = image.convert("RGB") #for safe
        image = image.resize((300, 280)) 

        #flaw 생성됨

        # 바이트 스트림으로 이미지 저장
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        await file.close()
        # 바이트 스트림을 반환
        img_byte_arr.seek(0)  # Seek to the start of the stream
        return img_byte_arr,10,20
    except Exception as e:
        print("Error:",e)
