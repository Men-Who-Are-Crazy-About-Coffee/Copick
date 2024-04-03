import io
from io import BytesIO
import os
import shutil
from PIL import Image, ImageDraw
from fastapi import File, UploadFile;
from jose import jwt,JWTError
import cv2
import numpy as np
from matplotlib import pyplot as plt
import extcolors
import requests
from ultralytics import YOLO

async def check_token(token: str):
    try:
        payload = jwt.decode(token,os.environ["JWT_SECRET_KEY"],algorithms=["HS512"])
        return payload
    except JWTError:
        raise JWTError("Invalid token")

async def extract_roasting(url:str):
    try:
        response = requests.get(url)
        image_data = BytesIO(response.content)
        image = Image.open(image_data)
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
        for c in colors:
            # 색상에 gap 값을 더합니다.
            adjusted_color = (
                max(0, min(255, c[0][0] + r_gap)),
                max(0, min(255, c[0][1] + g_gap)),
                max(0, min(255, c[0][2] + b_gap))
            )
            # 수정된 색상을 classify_roasting 함수에 전달합니다.
            roasting_type = await classify_roasting(adjusted_color)
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

async def manufacture_image(file,model):
    try:
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        image = image.convert("RGB") #for safe

        # results = model(source=image, conf=0.8)
        results = model(source=image)

        draw = ImageDraw.Draw(image)
        flaw_count = 0
        cropped_images = []

        for i, box in enumerate(results[0].boxes):
            x1, y1, x2, y2 = box.xyxy[0]
            if results[0].boxes.cls[i] < 2:
                crop = image.crop((box.xyxy[0].tolist()))
                cropped_img_byte_arr = io.BytesIO()
                crop.save(cropped_img_byte_arr, format='JPEG')
                cropped_img_byte_arr.seek(0)  # 스트림의 시작 위치로 커서 이동
                cropped_images.append(cropped_img_byte_arr)  # 리스트에 추가)

        # flaw 이미지 자르기 & sequence 이미지에 박스 그리기
        for i, box in enumerate(results[0].boxes):
            x1, y1, x2, y2 = box.xyxy[0]
            if results[0].boxes.cls[i] > 1 and results[0].boxes.conf[i] > 0.5:
                draw.rectangle([x1, y1, x2, y2], outline="green", width=4)

        for i, box in enumerate(results[0].boxes):
            x1, y1, x2, y2 = box.xyxy[0]
            if results[0].boxes.cls[i] < 2:
                draw.rectangle([x1, y1, x2, y2], outline="red", width=4)
                flaw_count += 1

        # # 이미지에 박스 그리기
        # for i, box in enumerate(results[0].obb.xyxy):
        #     x1, y1, x2, y2 = box.tolist()  # Tensor를 리스트로 변환
        #     # 클래스가 0이 아니거나(Good 이거나) conf가 0.8이하면 (Bad의 정확도가 0.8미만이면)
        #     if results[0].obb.cls[i] != 0 | results[0].obb.conf[i] < 0.8:  
        #         draw.rectangle([x1, y1, x2, y2], outline="green", width=4)
        #         continue
        #     draw.rectangle([x1, y1, x2, y2], outline="red", width=4)
        #     flaw_count += 1

        normal_count = results[0].boxes.cls.size()[0] - flaw_count
        # 바이트 스트림으로 이미지 저장
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        await file.close()
        # 바이트 스트림을 반환
        img_byte_arr.seek(0)  # Seek to the start of the stream
        return img_byte_arr,normal_count,flaw_count,cropped_images
    except Exception as e:
        print("Error:",e)   

def get_stream_video(model):
    # camera 정의
    cam = cv2.VideoCapture(0)

    while True:
        # 카메라 값 불러오기
        success, frame = cam.read()

        if not success:
            break
        else:
            ret, buffer = cv2.imencode('.jpg', frame)
            image = Image.open(io.BytesIO(buffer))
            # image = image.convert("RGB")  # for safe

            results = model(source=image, classes=[0], conf=0.8)

            # print(results)

            for r in results:
                im_array = r.plot()  # plot a BGR numpy array of predictions
                image = Image.fromarray(im_array[..., ::-1])  # RGB PIL image

            # draw = ImageDraw.Draw(image)

            # # 이미지에 박스 그리기
            # for i, box in enumerate(results[0].obb.xyxy):
            #     # 클래스가 0이 아니면 다음 바운딩 박스로 넘어갑니다.
            #     if results[0].obb.cls[i] != 0:
            #         continue
            #     x1, y1, x2, y2 = box.tolist()  # Tensor를 리스트로 변환
            #     draw.rectangle([x1, y1, x2, y2], outline="red", width=3)

            # `frame`에 최종 이미지의 바이트 데이터를 할당
            img_byte_arr = io.BytesIO()
            image.save(img_byte_arr, format='JPEG')
            frame = img_byte_arr.getvalue()  # 수정된 부분

            # yield로 하나씩 넘겨준다.
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' +
                   frame + b'\r\n')

def manufacture_video(frame_data,model):
    try:
        image = Image.open(io.BytesIO(frame_data))
        # image = image.convert("RGB") #for safe

        results = model(source=image, classes=[0], conf=0.8)

        for r in results:
                im_array = r.plot(labels=False)  # plot a BGR numpy array of predictions
                image = Image.fromarray(im_array[..., ::-1])  # RGB PIL image

        # 바이트 스트림으로 이미지 저장
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        # img_byte_arr.seek(0)  # Seek to the start of the stream
        # 바이트 스트림을 반환
        return img_byte_arr.getvalue()
    except Exception as e:
        print("Error:",e)