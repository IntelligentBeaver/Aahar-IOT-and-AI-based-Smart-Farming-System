import requests
from bs4 import BeautifulSoup
import json

# URL to scrape
url = "https://www.halokhabar.com/"

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

    # Find all anchor tags with specific news links
    a_elements = soup.find_all('a', href=True)

    # Extract data into a list of dictionaries
    articles_list = [
        {
            "title": a_element.get_text(strip=True),
            "url": a_element['href']
        }
        for a_element in a_elements if '/news-details/' in a_element['href']
    ]

    # Slice the list to keep only the first 10 articles
    sliced_articles = articles_list[:10]

    # Create the main variable with the parent key
    main_data = {
        "national_articles": sliced_articles
    }

    # Print the resulting JSON data
    print(json.dumps(main_data, ensure_ascii=False, indent=4))

else:
    print(f"Failed to retrieve the page. Status code: {response.status_code}")