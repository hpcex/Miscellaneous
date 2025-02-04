import os
from PyPDF2 import PdfReader, PdfWriter

def split_pdf():
    # 获取当前目录下所有的PDF文件
    pdf_files = [f for f in os.listdir('.') if f.endswith('.pdf')]

    if not pdf_files:
        print("当前目录下没有PDF文件！")
        input("按任意键退出...")
        return

    for pdf_file in pdf_files:
        try:
            # 读取PDF文件
            reader = PdfReader(pdf_file)
            total_pages = len(reader.pages)
            
            # 设置每个拆分文件的页数上限
            split_size = 1000
            
            # 拆分PDF
            for i in range(0, total_pages, split_size):
                writer = PdfWriter()
                split_file_name = f"{os.path.splitext(pdf_file)[0]}_part{i // split_size + 1}.pdf"
                
                for j in range(i, min(i + split_size, total_pages)):
                    writer.add_page(reader.pages[j])

                with open(split_file_name, "wb") as output_pdf:
                    writer.write(output_pdf)

                print(f"生成拆分文件: {split_file_name}")

        except Exception as e:
            print(f"处理文件 {pdf_file} 时出错：{e}")

    input("拆分完成，按任意键退出...")

if __name__ == "__main__":
    split_pdf()
