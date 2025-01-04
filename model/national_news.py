import requests
from bs4 import BeautifulSoup
import json

# URL to scrape
url = "https://agrotimes.com.np/"

# Headers to simulate a request from a web browser
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win 64; x64) AppleWebKit/537.36(KHTML, like Gecko) Chrome/80.0.3987.162 Safari/537.36'
}

# Send a GET request to fetch the HTML content of the page
response = requests.get(url, headers=headers)

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Parse the HTML content with BeautifulSoup
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find all h2 elements with class 'post-title'
    h2_elements = soup.find_all('h2', class_='post-title')

    # Extract data into a list of dictionaries
    articles_list = [
        {
            "title": h2_element.get_text(strip=True),
            "url": h2_element.find('a')['href']
        }
        for h2_element in h2_elements
    ]

    # Create the main variable with the parent key
    main_data = {
        "national_articles": articles_list
    }

    # Print the resulting JSON data
    print(json.dumps(main_data, ensure_ascii=False, indent=4))

else:
    print(f"Failed to retrieve the page. Status code: {response.status_code}")
