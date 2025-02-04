import ctypes
import pyperclip

def set_clipboard_as_gbk():
    try:
        # 获取剪贴板中的文本内容
        clipboard_data = pyperclip.paste()
        if not clipboard_data:
            return

        # 将文本内容转换为 GBK 编码的字节数据
        gbk_data = clipboard_data.encode('gbk', errors='replace')

        # 打开剪贴板
        if not ctypes.windll.user32.OpenClipboard(0):
            raise RuntimeError("无法打开剪贴板")

        # 清空剪贴板
        ctypes.windll.user32.EmptyClipboard()

        # 分配全局内存并写入 GBK 数据
        h_global_mem = ctypes.windll.kernel32.GlobalAlloc(0x2000, len(gbk_data) + 1)
        lp_global_mem = ctypes.windll.kernel32.GlobalLock(h_global_mem)
        ctypes.memmove(lp_global_mem, gbk_data, len(gbk_data))
        ctypes.windll.kernel32.GlobalUnlock(h_global_mem)

        # 设置剪贴板数据类型为 CF_TEXT（ANSI 文本）
        ctypes.windll.user32.SetClipboardData(1, h_global_mem)

        # 关闭剪贴板
        ctypes.windll.user32.CloseClipboard()
    except Exception as e:
        print(f"发生错误: {e}")

# 执行操作
set_clipboard_as_gbk()
