# 读取目录下的第一个tif文件，获取他的宽度，然后把目录下所有的jpg都改成这个宽读，长宽比不变。
# pip install Pillow

import os
from PIL import Image

def resize_jpgs_to_tif_width(directory):
    # 获取目录下的所有文件
    files = os.listdir(directory)
    
    # 找到第一个 tif 文件
    tif_file = next((f for f in files if f.lower().endswith('.tif')), None)
    
    if tif_file is None:
        print("没有找到 tif 文件。")
        return
    
    # 获取 tif 文件的宽度
    tif_path = os.path.join(directory, tif_file)
    with Image.open(tif_path) as img:
        tif_width = img.width
    
    print(f"TIF 文件的宽度: {tif_width}")
    
    # 遍历目录下的所有 jpg 文件并调整大小
    for f in files:
        if f.lower().endswith('.jpg'):
            jpg_path = os.path.join(directory, f)
            with Image.open(jpg_path) as img:
                # 计算新的高度，保持长宽比
                aspect_ratio = img.height / img.width
                new_height = int(tif_width * aspect_ratio)
                
                # 调整大小并保存
                # resized_img = img.resize((tif_width, new_height), Image.ANTIALIAS)
                resized_img = img.resize((tif_width, new_height), Image.LANCZOS)
                resized_img.save(jpg_path)
                print(f"已调整大小并保存: {jpg_path}")

if __name__ == "__main__":
    # 替换为你的目录路径
    directory_path = '.'  # 当前目录
    resize_jpgs_to_tif_width(directory_path)
