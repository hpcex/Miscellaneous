# 使用矩阵变换来统一PDF文件页面的宽度，并保持长宽比，不出现白色填充。
# By 老实和尚
# 2024-12-08 16:08
# 使用方法：把脚本和pdf放在同一个目录下，运行脚本。
 
import pikepdf
import os

# 获取当前目录
current_directory = os.getcwd()

# 获取当前目录下所有PDF文件
pdf_files = [f for f in os.listdir(current_directory) if f.lower().endswith('.pdf')]

# 遍历每个PDF文件
for input_file in pdf_files:
    output_file = input_file.replace('.pdf', '_new.pdf')

    # 打开PDF
    try:
        pdf = pikepdf.Pdf.open(input_file)

        # 找到最大宽度
        max_width = 0
        for page in pdf.pages:
            mediabox = page.mediabox
            current_width = abs(float(mediabox[2] - mediabox[0]))
            max_width = max(max_width, current_width)

        # 提示用户输入自定义宽度（单位：cm）
        user_input = input(f"处理文件 {input_file}: 请输入自定义宽度(单位:cm)，直接回车使用最大宽度 {max_width / 28.35:.2f} cm: ")

        # 如果用户输入了宽度，则使用用户输入的宽度，否则使用最大宽度
        if user_input.strip() != "":
            standard_width_cm = float(user_input)
            standard_width_pt = standard_width_cm * 28.35  # 将厘米转换为点（1 cm = 28.35 pt）
        else:
            standard_width_pt = max_width

        # 遍历每一页并调整
        for page_index, page in enumerate(pdf.pages):
            try:
                # 获取当前页面的媒体框
                mediabox = page.mediabox
                current_width = abs(float(mediabox[2] - mediabox[0]))
                current_height = abs(float(mediabox[3] - mediabox[1]))

                # 判断缩放类型
                if current_width > standard_width_pt:
                    # 页面需要缩小
                    scale_factor = standard_width_pt / current_width
                    new_mediabox = [
                        round(float(mediabox[0]) * scale_factor, 2),  # 保留两位小数
                        round(float(mediabox[1]) * scale_factor, 2),  # 保留两位小数
                        round(float(mediabox[2]) * scale_factor, 2),  # 保留两位小数
                        round(float(mediabox[3]) * scale_factor, 2)   # 保留两位小数
                    ]
                    page.mediabox = pikepdf.Array(new_mediabox)

                    if '/CropBox' in page:
                        page.CropBox = pikepdf.Array(new_mediabox)

                    print(f"页面 {page_index} 缩小处理完成")
                else:
                    # 页面需要放大
                    scale_factor = standard_width_pt / current_width
                    new_mediabox = [
                        round(float(mediabox[0]) * scale_factor, 2),  # 保留两位小数
                        round(float(mediabox[1]) * scale_factor, 2),  # 保留两位小数
                        round(float(mediabox[2]) * scale_factor, 2),  # 保留两位小数
                        round(float(mediabox[3]) * scale_factor, 2)   # 保留两位小数
                    ]
                    page.mediabox = pikepdf.Array(new_mediabox)

                    if '/CropBox' in page:
                        page.CropBox = pikepdf.Array(new_mediabox)

                    print(f"页面 {page_index} 放大处理完成")

                # 保存页面原来的内容流
                original_content = b""
                if page.Contents is not None:
                    if isinstance(page.Contents, pikepdf.Array):
                        for stream in page.Contents:
                            if isinstance(stream, pikepdf.Stream):
                                original_content += stream.read_bytes()
                    else:
                        original_content = page.Contents.read_bytes()

                transform_matrix = (
                    f"{scale_factor} 0 0 {scale_factor} 0 0 cm\n"
                ).encode("utf-8")
                optimized_content = transform_matrix + original_content + b"\n"

                # 创建新的内容流
                new_stream = pikepdf.Stream(pdf, optimized_content)
                page.Contents = new_stream

            except Exception as e:
                print(f"页面 {page_index} 处理失败: {e}")

        # 保存PDF
        try:
            pdf.save(output_file)
            print(f"PDF处理完成。输出保存到 {output_file}")
        except Exception as e:
            print(f"错误: 无法保存 PDF,原因: {e}")
    
    except Exception as e:
        print(f"无法打开文件 {input_file}: {e}")