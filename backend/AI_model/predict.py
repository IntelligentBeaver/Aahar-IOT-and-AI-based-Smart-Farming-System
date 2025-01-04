import os
import pickle
import joblib
import requests
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem import SnowballStemmer
import nltk
import json

# Ensure the required NLTK data packages are downloaded
nltk.download('stopwords')

# Initialize the stemmer and tokenizer
stemmer = SnowballStemmer('english')
tokenizer = RegexpTokenizer(r'[A-Za-z]+')

# Function to preprocess the text
def transform_text(text):
    # Tokenizing the text
    tokens = tokenizer.tokenize(text.lower())
    
    # Removing stopwords and stemming
    stop_words = set(stopwords.words('english'))
    processed_tokens = [stemmer.stem(word) for word in tokens if word not in stop_words]
    
    # Joining tokens back into a string
    return " ".join(processed_tokens)

# Function to fetch news titles from API
def fetch_news_titles(api_url):
    try:
        response = requests.get(api_url)
        if response.status_code == 200:
            data = response.json()
            news_data = [
                {
                    "description": source.get("description", "No description available"),
                    "url": source.get("url", "No URL available")
                }
                for source in data.get("results", [])
            ]
        else:
            print(f"Failed to fetch data, status code: {response.status_code}")
            news_data = []
    except Exception as e:
        print(f"Error fetching news titles: {e}")
        news_data = []
    return news_data

# Load the vectorizer and model
base_dir = os.path.dirname(os.path.abspath(__file__))
vectorizer_path = os.path.join(base_dir, 'count_vectorizer.pkl')
model_path = os.path.join(base_dir, 'model.pkl')

try:
    vectorizer = joblib.load(open(vectorizer_path, 'rb'))
    model = pickle.load(open(model_path, 'rb'))
except Exception as e:
    print(f"Error loading model or vectorizer: {e}")
    vectorizer = None
    model = None

# Main Logic for Fetching News from API
def fetch_and_predict_from_api(api_url):
    result_json = {"filtered_results": []}
    if vectorizer and model:
        news_data = fetch_news_titles(api_url)
        
        # Adding custom examples
        news_data.extend([
            {"description": "Secretary of Agriculture leads a must-see tour of the PA Farm Show [photos]",
             "url": "https://lancasteronline.com/features/entertainment/secretary-of-agriculture-leads-a-must-see-tour-of-the-pa-farm-show-photos/collection_55b7f128-c95f-11ef-bdcb-bb48978e8bc3.html"},
            {"description": "Rajasthan Farmer Manoj Khandelwal Earns Rs 50,000 Per Bigha Through Diversified Organic Farming",
             "url": "https://krishijagran.com/success-story/rajasthan-farmer-manoj-khandelwal-earns-rs-50-000-per-bigha-through-diversified-organic-farming/"},
            {"description": "‘Murder Hornet’ Eradicated in the US: What It Means for Pollinators and Agriculture",
             "url": "https://krishijagran.com/agriculture-world/murder-hornet-eradicated-in-the-us-what-it-means-for-pollinators-and-agriculture/"}
        ])
        
        # Predict for each news title
        for item in news_data:
            description = item['description']
            url = item['url']
            if description != 'No description available':
                transformed_news = transform_text(description)
                vector_input = vectorizer.transform([transformed_news])
                prediction = model.predict(vector_input)[0]
                if prediction == 1:  # Include only items with prediction = 1
                    result_json["filtered_results"].append({"title": description, "url": url})
        
        # Check if results are found
        if not result_json["filtered_results"]:
            result_json['message'] = "No related news found."
    else:
        result_json['error'] = "Vectorizer or model is not loaded."
    
    return json.dumps(result_json)

# Example usage:
# API-based news fetch and prediction
api_url = "https://newsdata.io/api/1/sources?country=np&apikey=pub_62266aba0643a6bf2b5c2df1f89b66249cd53"
print(fetch_and_predict_from_api(api_url))