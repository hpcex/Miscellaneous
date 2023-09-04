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
    repo_url = "https://github.com/SagerNet/sing-geosite/releases/latest"
    latest_release_tag = get_latest_release_tag(repo_url)

    if latest_release_tag:
        geosite_db_url = f"https://github.com/SagerNet/sing-geosite/releases/download/{latest_release_tag}/geosite.db"
        save_path = os.path.join(os.getcwd(), "geosite.db")
        
        response = requests.get(geosite_db_url)
        if response.status_code == 200:
            with open(save_path, 'wb') as file:
                file.write(response.content)
            print("Download successful")
        else:
            print("Download failed")
    else:
        print("Unable to get the latest release tag")
