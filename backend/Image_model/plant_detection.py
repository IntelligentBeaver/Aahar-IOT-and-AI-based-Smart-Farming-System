# Import necessary libraries
import tensorflow as tf
from tensorflow.keras.models import load_model
import numpy as np
from PIL import Image
import os

# Suppress TensorFlow logs
import tensorflow as tf
tf.get_logger().setLevel('ERROR')

# Load the saved model
try:
    model = load_model("mobilenetv2_model.keras")
    print("Model loaded successfully.")
except Exception as e:
    print(f"Error loading model: {e}")
    exit()

# Define image preprocessing function
def preprocess_image(image_path, img_height=224, img_width=224):
    try:
        # Check if the file exists
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image file not found: {image_path}")

        # Load the image using PIL
        with Image.open(image_path) as img:
            # Convert to RGB
            image_rgb = img.convert("RGB")

            # Resize the image
            image_resized = image_rgb.resize((img_height, img_width))

            # Convert to NumPy array
            image_array = np.array(image_resized)

            # Normalize pixel values to [0, 1]
            image_normalized = image_array / 255.0

            # Add an additional dimension for batch size
            image_preprocessed = np.expand_dims(image_normalized, axis=0)

            return image_preprocessed
    except Exception as e:
        print(f"Error preprocessing image: {e}")
        return None

# Function to predict image class
def predict_image(image_path, model, class_names):
    # Preprocess the image
    preprocessed_image = preprocess_image(image_path)

    if preprocessed_image is not None:
        try:
            # Make predictions
            predictions = model.predict(preprocessed_image)

            # Get the index of the highest predicted score
            predicted_index = np.argmax(predictions[0])

            # Get the corresponding class name
            predicted_class = class_names[predicted_index]

            # Get the confidence score
            confidence_score = predictions[0][predicted_index]

            return predicted_class, confidence_score
        except Exception as e:
            print(f"Error during prediction: {e}")
            return None, None
    else:
        return None, None

# Path to the image to predict
image_path = "tomato.jpeg"

# Define the class names
class_names = ['Normal', 'Fungi', 'Bacteria', 'Nematodes', 'Virus']

# Predict the class of the image
predicted_class, confidence = predict_image(image_path, model, class_names)

if predicted_class is not None:
    print(f"Predicted Class: {predicted_class}")
    print(f"Confidence Score: {confidence:.2f}")
else:
    print("Error in prediction. Please check the image or model.")
