import os
import sys

try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    GREEN = Fore.GREEN
except ImportError:
    # 如果没有colorama，使用ANSI转义码
    class Fore:
        GREEN = '\033[92m'  # 亮绿色
        YELLOW = '\033[93m'  # 最亮的黄色
    class Style:
        RESET_ALL = '\033[0m'

def rename_files_to_pdg(directory='.'):
    """
    将指定目录下的所有文件重命名为.pdg后缀，并统计信息
    
    :param directory: 要处理的目录路径，默认为当前目录
    :return: 返回.pdg文件的数量和总大小（字节）
    """
    pdg_count = 0
    pdg_total_size = 0

    # 获取当前脚本的文件名
    current_script = os.path.basename(sys.argv[0])

    # 遍历目录下的所有文件
    for filename in os.listdir(directory):
        # 跳过当前脚本
        if filename == current_script:
            continue

        # 获取文件的完整路径
        filepath = os.path.join(directory, filename)
        
        # 确保是文件，不是目录
        if os.path.isfile(filepath):
            # 获取文件名和扩展名
            name, ext = os.path.splitext(filename)
            
            # 新的文件名
            new_filename = f"{name}.pdg"
            new_filepath = os.path.join(directory, new_filename)
            
            try:
                # 重命名文件
                os.rename(filepath, new_filepath)
                
                # 更新统计信息
                pdg_count += 1
                pdg_total_size += os.path.getsize(new_filepath)
                
                print(f"已重命名: {filename} -> {new_filename}")
            except Exception as e:
                print(f"重命名 {filename} 失败: {e}")

    return pdg_count, pdg_total_size

def main():
    # 执行重命名并获取统计信息
    count, total_size = rename_files_to_pdg()
    
    # 输出结果
    print(f"\n{Style.BRIGHT}{Fore.YELLOW}统计结果:{Style.RESET_ALL}")
    print(f"{Style.BRIGHT}{Fore.YELLOW}PDG文件总页数:{Style.RESET_ALL} {Style.BRIGHT}{Fore.YELLOW}{count}{Style.RESET_ALL}")
    print(f"{Style.BRIGHT}{Fore.YELLOW}PDG文件总大小:{Style.RESET_ALL} {Style.BRIGHT}{Fore.YELLOW}{total_size / (1024 * 1024):.2f} MB{Style.RESET_ALL}")
    
    # 等待用户按回车键退出
    input("\n按回车键退出...")

if __name__ == "__main__":
    main()