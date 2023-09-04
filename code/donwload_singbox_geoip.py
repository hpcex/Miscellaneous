import os
import requests
from bs4 import BeautifulSoup

def get_latest_release_tag(repo_url):
    response = requests.get(repo_url)
    
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        tag_element = soup.find("span", class_="css-truncate-target")
        
        if tag_element:
            return tag_element.text.strip()
        else:
            print("Failed to extract release tag")
    else:
        print("Failed to access repository page")

    return None

if __name__ == "__main__":
    repo_owner = "SagerNet"
    repo_name = "sing-geoip"
    repo_url = f"https://github.com/{repo_owner}/{repo_name}/releases/latest"
    
    latest_release_tag = get_latest_release_tag(repo_url)

    if latest_release_tag:
        geoip_db_url = f"https://github.com/{repo_owner}/{repo_name}/releases/download/{latest_release_tag}/geoip.db"
        save_path = os.path.join(os.getcwd(), "geoip.db")
        
        response = requests.get(geoip_db_url)
        if response.status_code == 200:
            with open(save_path, 'wb') as file:
                file.write(response.content)
            print("Download successful")
        else:
            print("Download failed")
    else:
        print("Unable to get the latest release tag")
