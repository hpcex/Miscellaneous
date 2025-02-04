import os
from PyPDF2 import PdfReader, PdfWriter

def merge_pdfs():
    # 获取当前目录下所有的PDF文件
    pdf_files = [f for f in os.listdir('.') if f.endswith('.pdf')]

    if len(pdf_files) != 2:
        print("当前目录下必须有且仅有两个PDF文件！")
        input("按任意键退出...")
        return

    # 按文件大小排序，体积大的在前
    pdf_files.sort(key=lambda f: os.path.getsize(f), reverse=True)

    try:
        # 创建PDF Writer实例
        writer = PdfWriter()

        for pdf_file in pdf_files:
            # 读取PDF文件
            reader = PdfReader(pdf_file)
            for page in reader.pages:
                writer.add_page(page)

        # 自定义元数据
        writer.add_metadata({
            #"/Title": "自定义合并PDF",
            #"/Author": "您的姓名",
            "/Producer": "hehe"
        })

        # 输出合并后的PDF
        output_file = "merged.pdf"
        with open(output_file, "wb") as f:
            writer.write(f)

        print(f"PDF合并成功，输出文件为：{output_file}")
        input("按任意键退出...")

    except Exception as e:
        print(f"合并PDF时出错：{e}")
        input("按任意键退出...")

if __name__ == "__main__":
    merge_pdfs()
