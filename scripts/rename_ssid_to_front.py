# 把文件名末尾的8位ssid移到文件名的开头
# by 老实和尚 2025-02-04 21:12

import os
import re

# 获取当前目录下的所有文件
directory = os.getcwd()

# 遍历文件列表
for filename in os.listdir(directory):
    # 判断文件是否是目标格式（pdf、zip、uvz）
    if filename.endswith(('.pdf', '.zip', '.uvz')):
        # 提取文件扩展名
        ext = filename.split('.')[-1]

        # 获取文件名去掉扩展名
        base_name = filename.rsplit('.', 1)[0]

        # 判断文件名是否以8位数字结尾
        if len(base_name) > 8 and base_name[-8:].isdigit():
            # 提取最后8个字符（数字部分）
            number = base_name[-8:]

            # 去掉文件名结尾的下划线（如果存在）
            base_name_without_number = base_name[:-8].rstrip('_')

            # 删除末尾的空格
            base_name_without_number = base_name_without_number.rstrip()

            # 替换文件名中的多个空格为一个下划线
            base_name_without_number = re.sub(
                r'\s+', '_', base_name_without_number)

            # 重构新的文件名
            new_filename = f"{number}_{base_name_without_number}.{ext}"

            # 获取完整的旧文件路径和新文件路径
            old_filepath = os.path.join(directory, filename)
            new_filepath = os.path.join(directory, new_filename)

            # 重命名文件
            os.rename(old_filepath, new_filepath)
            print(f"Renamed: {filename} -> {new_filename}")
        else:
            print(f"Ignored: {filename} (does not end with 8 ssid)")
