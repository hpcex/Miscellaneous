# 借助 wkhtmltopdf,将markdown转为pdf.
# by 老实和尚
# v1.1
# 2025-01-07 12:48

import os
import markdown
import pdfkit
import re

# 设置 wkhtmltopdf 的路径，确保路径指向实际的 wkhtmltopdf.exe 文件
pdfkit_config = pdfkit.configuration(
    wkhtmltopdf=r'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe')

# 获取当前目录下的所有的 md 文件


def get_md_files():
    md_files = [f for f in os.listdir('.') if f.endswith('.md')]
    return md_files

# 判断是否是中文字符


def is_chinese(c):
    return '\u4e00' <= c <= '\u9fff'

# 将 Markdown 内容中的半角标点转换为全角


def convert_punctuation(md_content):
    result = []
    for i in range(len(md_content)):
        # 如果是中文字符，且紧跟着的标点是半角，则转换为全角
        if is_chinese(md_content[i]) and i + 1 < len(md_content):
            if md_content[i + 1] in ['.', ',', '!', '?', ':', ';', '(', ')', '[', ']', '{', '}', '<', '>', '"', "'", '...']:
                # 只转换半角标点
                char_map = {
                    '.': '。', ',': '，', '!': '！', '?': '？',
                    ':': '：', ';': '；', '(': '（', ')': '）',
                    '[': '【', ']': '】', '{': '｛', '}': '｝',
                    '<': '＜', '>': '＞', '"': '“', "'": '‘',
                    '...': '……'  # 处理省略号
                }
                next_char = md_content[i + 1]
                result.append(md_content[i])
                result.append(char_map.get(next_char, next_char))
                i += 1
            else:
                result.append(md_content[i])
        else:
            result.append(md_content[i])
    return ''.join(result)

# 将 Markdown 文件转换为 HTML


def md_to_html(md_file):
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()

    # 转换半角标点为中文全角标点（仅在中文字符结尾时）
    md_content = convert_punctuation(md_content)

    # 将 Markdown 转换为 HTML
    html_content = markdown.markdown(md_content)

    # 去除不必要的 <pre> 标签，尤其是出现在标题之前的
    html_content = re.sub(r'<pre.*?>.*?</pre>', '',
                          html_content, flags=re.DOTALL)

    # 在 HTML 中添加自定义样式，优化中文排版
    html_template = f"""
    <!DOCTYPE html>
    <html lang="zh">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{md_file}</title>
        <style>
            html, body {{
                margin: 0;
                padding: 0;
                background: #FFFFFF;
                box-sizing: border-box;
                overflow: hidden;
            }}
            
            body {{
                font-family: "微软雅黑", "宋体", "黑体", Arial, sans-serif;
                font-size: 16px;
                line-height: 1.5;  /* 设置行间距 */
                word-wrap: break-word;
                word-break: break-all;
                padding-top: 0 !important;
                box-shadow: none !important;
                width: 100%;
                margin: 0;
            }}
            
            p {{
                margin-bottom: 1.2em; /* 设置段间距 */
                text-indent: 2em;
                font-family: "宋体", "黑体", sans-serif;
                font-size: 16px;
                width: 90%;  /* 设置文本区域宽度 */
                max-width: 800px;  /* 每行字符数的最大宽度 */
                word-wrap: break-word;  /* 自动换行 */
                word-break: break-all;  /* 确保长词能换行 */
                margin-left: auto;
                margin-right: auto;
            }}
            
            h1, h2, h3, h4, h5, h6 {{
                color: #333;
                font-family: "微软雅黑", sans-serif;
                font-weight: bold;
            }}
            
            ul, ol {{
                margin-left: 2em;
                font-family: "宋体", "黑体", sans-serif;
            }}
            
            pre {{
                background-color: #F4F4F4;
                padding: 10px;
                font-family: Consolas, monospace;
                font-size: 14px;
            }}
            
            @page {{
                size: A4;
                margin: 10mm;
            }}

            .page-footer {{
                position: fixed;
                bottom: 10mm;
                right: 10mm;
                font-size: 12px;
                text-align: right;
            }}
        </style>
    </head>
    <body>
        {html_content}
    </body>
    </html>
    """
    return html_template

# 将 HTML 转换为 PDF


def html_to_pdf(html_content, pdf_file):
    options = {
        'margin-top': '10mm',
        'margin-bottom': '10mm',
        # 'margin-left': '5mm',
        # 'margin-right': '5mm',
        'footer-right': '[page] of [topage]',  # 右下角页码
        'footer-font-size': '8',  # 页码字体大小
        'footer-spacing': '3',  # 页码与底部的间距
    }
    pdfkit.from_string(html_content, pdf_file,
                       configuration=pdfkit_config, options=options)


def convert_md_to_pdf():
    md_files = get_md_files()
    if not md_files:
        print("没有找到 Markdown 文件。")
        return

    for md_file in md_files:
        print(f"正在转换 {md_file}...")
        html_content = md_to_html(md_file)
        pdf_file = md_file.replace('.md', '.pdf')
        html_to_pdf(html_content, pdf_file)
        print(f"{md_file} 转换为 PDF 成功！")


if __name__ == '__main__':
    convert_md_to_pdf()
