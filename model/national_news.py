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

    # List to store the extracted data
    articles = []

    # Loop through all the h2 elements and extract the title and URL
    for h2_element in h2_elements:
        title = h2_element.get_text(strip=True)
        href = h2_element.find('a')['href']
        articles.append({"title": title, "url": href})

    # Discard the top 3 entries by slicing the list
    articles = articles[3:]

    # Convert the list to JSON format and print
    print(json.dumps(articles, ensure_ascii=False, indent=4))

else:
    print(f"Failed to retrieve the page. Status code: {response.status_code}")
