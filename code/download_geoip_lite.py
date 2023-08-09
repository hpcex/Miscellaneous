import requests
import re

def get_geoip_download_url():
    url = 'https://api.github.com/repos/v2fly/geoip/releases/latest'
    response = requests.get(url)
    
    if response.status_code == 200:
        json_data = response.json()
        assets = json_data.get('assets', [])
        for asset in assets:
            download_url = asset.get('browser_download_url')
            if download_url and 'geoip-only-cn-private.dat' in download_url:
                return download_url
    else:
        print(f'Failed to access GitHub API. Status code: {response.status_code}')
    
    return None

def download_geoip_file(url):
    response = requests.get(url)
    
    if response.status_code == 200:
        with open('geoip-only-cn-private.dat', 'wb') as f:
            f.write(response.content)
        print('Download completed!')
    else:
        print(f'Failed to download file. Status code: {response.status_code}')

if __name__ == '__main__':
    download_url = get_geoip_download_url()
    if download_url:
        download_geoip_file(download_url)
    else:
        print('Failed to find the download link for geoip-only-cn-private.dat')
