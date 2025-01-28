import requests
from bs4 import BeautifulSoup
import json

# URLs to scrape
primary_url = "https://agrotimes.com.np/"
fallback_urls = [
    "https://www.halokhabar.com/",
    "https://krishidaily.com/",
    "https://english.onlinekhabar.com/tag/nepal-agriculture",
    "https://kathmandupost.com/money/2025/01/27/vegetable-prices-drop-amid-winter-harvest-pesticide-concerns"
]

# Headers to simulate a request from a web browser
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Safari/537.36'
}

# Function to scrape articles from a given URL
def scrape_articles(url):
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        # Adjust the selectors based on the website structure
        h2_elements = soup.find_all('h2')
        return [
            {
                "title": h2.get_text(strip=True),
                "url": h2.find('a')['href'] if h2.find('a') else None
            }
            for h2 in h2_elements if h2.find('a')
        ]
    return []

# Main logic to fetch data
try:
    # Try scraping from the primary source
    articles_list = scrape_articles(primary_url)
    if not articles_list:
        raise Exception("No articles found in primary source.")
except Exception as e:
    # If primary source fails, use static fallback data
    print(f"Primary source failed: {e}")
    articles_list = [{"url": url} for url in fallback_urls]

# Create the main variable with the parent key
main_data = {
    "national_articles": articles_list
}

# Print the resulting JSON data
print(json.dumps(main_data, ensure_ascii=False, indent=4))
