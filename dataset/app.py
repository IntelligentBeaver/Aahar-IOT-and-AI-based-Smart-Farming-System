import json
import joblib
import pickle
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
def transform_text(text):
    # Convert text to lowercase
    text = text.lower()
    
    # Tokenize the text
    tokens = tokenizer.tokenize(text)
    
    # Remove stop words and stem the remaining tokens
    stop_words = set(stopwords.words('english'))
    processed_tokens = [stemmer.stem(word) for word in tokens if word not in stop_words]
    
    # Join the stemmed tokens into a single string
    transformed_text = ' '.join(processed_tokens)
    return transformed_text

# Load the pre-trained models
cv = joblib.load(open('count_vectorizer.pkl', 'rb'))
model = pickle.load(open('model.pkl', 'rb'))

# Sample news data (can be fetched via API or manually inputted)
news_data = [
    {"description": "Secretary of Agriculture leads a must-see tour of the PA Farm Show [photos]",
     "url": "https://lancasteronline.com/features/entertainment/secretary-of-agriculture-leads-a-must-see-tour-of-the-pa-farm-show-photos/collection_55b7f128-c95f-11ef-bdcb-bb48978e8bc3.html"},
    {"description": "Rajasthan Farmer Manoj Khandelwal Earns Rs 50,000 Per Bigha Through Diversified Organic Farming",
     "url": "https://krishijagran.com/success-story/rajasthan-farmer-manoj-khandelwal-earns-rs-50-000-per-bigha-through-diversified-organic-farming/"},
    {"description": "‘Murder Hornet’ Eradicated in the US: What It Means for Pollinators and Agriculture",
     "url": "https://krishijagran.com/agriculture-world/murder-hornet-eradicated-in-the-us-what-it-means-for-pollinators-and-agriculture/"},
    {"description": "Random non-agriculture news about technology advancements in 2025",
     "url": "https://example.com/technology-2025"}
]

# Predict for each news item
filtered_results = []
for item in news_data:
    description = item['description']
    url = item['url']
    transformed_news = transform_text(description)
    vector_input = cv.transform([transformed_news])
    prediction = model.predict(vector_input)[0]
    if prediction == 1:  # Include only items with prediction = 1
        filtered_results.append({"title": description, "url": url})

# Output filtered results as JSON
output_json = json.dumps(filtered_results, indent=4)
print(output_json)
