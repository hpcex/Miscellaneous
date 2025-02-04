import os
from PyPDF2 import PdfReader

def points_to_cm(points):
    return float(points) * 2.54 / 72  # 将点转换为厘米

def check_pdf_page_widths(pdf_path, log_file):
    try:
        with open(pdf_path, 'rb') as f:
            reader = PdfReader(f)
            widths = []
            
            for page in reader.pages:
                media_box = page.mediabox
                width = abs(media_box[2] - media_box[0])  # 计算宽度
                width_cm = points_to_cm(width)  # 转换为厘米
                widths.append(width_cm)
            
            # 检查所有页的宽度是否相同
            if all(width == widths[0] for width in widths):
                result = f"{pdf_path}: 所有页宽度相同 ({widths[0]:.2f} cm)\n"
            else:
                max_width = max(widths)
                max_width_index = widths.index(max_width)
                result = (f"{pdf_path}: 页宽度不相同 ({', '.join(f'{w:.2f} cm' for w in widths)})\n"
                          f"最大宽度的页: 页索引 {max_width_index}, 宽度 {max_width:.2f} cm\n")
            
            # 将结果写入日志文件
            with open(log_file, 'a', encoding='utf-8') as log:
                log.write(result)
    
    except Exception as e:
        error_message = f"处理文件 {pdf_path} 时出错: {e}\n"
        with open(log_file, 'a', encoding='utf-8') as log:
            log.write(error_message)

def check_pdfs_in_directory(directory, log_file):
    for filename in os.listdir(directory):
        if filename.endswith('.pdf'):
            pdf_path = os.path.join(directory, filename)
            check_pdf_page_widths(pdf_path, log_file)

if __name__ == "__main__":
    directory = input("请输入要检查的PDF文件夹路径: ")
    log_file = 'check.log'  # 日志文件名
    check_pdfs_in_directory(directory, log_file)
    print(f"检查结果已输出到 {log_file}")
