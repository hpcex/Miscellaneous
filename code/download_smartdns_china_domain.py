import urllib.request

# 下载文件到本地
url = "https://cdn.jsdelivr.net/gh/felixonmars/dnsmasq-china-list/accelerated-domains.china.conf"
filename = "accelerated-domains.china.conf"

urllib.request.urlretrieve(url, filename)

# 打开下载的文件并处理
with open(filename, "r") as file:
    lines = file.readlines()

# 提取每行的域名并去掉开头的"server=/"和结尾的"/114.114.114.114"，只保留域名部分
domains = [line.strip("server=/").split("/")[0] for line in lines if "#" not in line]

# 将提取的域名保存到文件中
with open("china.conf", "w") as domain_file:
    domain_file.write("\n".join(domains))

print("域名已提取并保存到文件 china.conf 中。")

# 删除下载的文件
import os
os.remove(filename)
