import os
import pickle
import joblib
import requests
import streamlit as st
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem import SnowballStemmer
import nltk

# Ensure the required NLTK data packages are downloaded
nltk.download('stopwords')

# Initialize the stemmer and tokenizer
stemmer = SnowballStemmer('english')
tokenizer = RegexpTokenizer(r'[A-Za-z]+')

# Function to preprocess the text

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
            st.error(f"Failed to fetch data, status code: {response.status_code}")
            news_data = []
    except Exception as e:
        st.error(f"Error fetching news titles: {e}")
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
    st.error(f"Error loading model or vectorizer: {e}")
    vectorizer = None
    model = None

# Streamlit UI
st.title("News Detection System")

# Input method: Manual or Fetch from API
option = st.selectbox("Choose Input Method", ["Manual Input", "Fetch from API"])

if option == "Manual Input":
    # Text area for input
    input_sms = st.text_area("Enter the message")

    # Predict button
    if st.button("Predict"):
        if vectorizer and model:
            # Preprocess the input
            transformed_news = transform_text(input_sms)
            
            # Vectorize the input
            vector_input = vectorizer.transform([transformed_news])
            
            # Predict using the loaded model
            result = model.predict(vector_input)[0]
            
            # Display the result
            if result == 1:
                st.header("Related")
            else:
                st.header("Not Related")
        else:
            st.error("Vectorizer or model is not loaded.")

elif option == "Fetch from API":
    # API URL to fetch news titles
    api_url = "https://newsdata.io/api/1/sources?country=np&apikey=pub_62266aba0643a6bf2b5c2df1f89b66249cd53"

    # Fetch and process news titles
    if st.button("Fetch News"):
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
            filtered_results = []
            for item in news_data:
                description = item['description']
                url = item['url']
                if description != 'No description available':
                    transformed_news = transform_text(description)
                    vector_input = vectorizer.transform([transformed_news])
                    prediction = model.predict(vector_input)[0]
                    if prediction == 1:  # Include only items with prediction = 1
                        filtered_results.append({"title": description, "url": url})

            # Display results
            if filtered_results:
                st.subheader("Filtered Results:")
                for result in filtered_results:
                    st.write(f"- [{result['title']}]({result['url']})")
            else:
                st.info("No related news found.")
        else:
            st.error("Vectorizer or model is not loaded.")
