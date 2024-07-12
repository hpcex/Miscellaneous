import os
import requests
import shutil
import time

# Download files using the URLs


def download_file(url, save_path):
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(save_path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
        print(f"Downloaded {save_path}")
    else:
        print(f"Failed to download {url}")


# URLs and file paths
urls_and_paths = [
    ("https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat",
     "d:\\incom\\geoip.dat"),
    ("https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat",
     "d:\\incom\\geosite.dat"),
    ("https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/geoip-only-cn-private.dat",
     "d:\\incom\\geoip-only-cn-private.dat")
]

# Download files
for url, save_path in urls_and_paths:
    download_file(url, save_path)

# Pause for 3 seconds
# time.sleep(3)

# Pause for user input
# input("Press Enter to exit...")
