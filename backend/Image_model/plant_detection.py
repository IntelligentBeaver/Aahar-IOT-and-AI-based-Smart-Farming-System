import os
import logging
import argparse

# Suppress TensorFlow and absl logs before TensorFlow is imported
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # Suppresses INFO logs (set to '3' to suppress only errors)
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'  # Optionally disable oneDNN optimizations
os.environ['TF_LOG_LEVEL'] = '2'  # Optional: Control TensorFlow log verbosity

# Suppress absl logging warnings
logging.getLogger('absl').setLevel(logging.ERROR)
import tensorflow as tf
import numpy as np
from PIL import Image

# Load the saved model
def load_trained_model(model_path):
    try:
        model = tf.keras.models.load_model(model_path)
        print("Model loaded successfully.")
        return model
    except Exception as e:
        print(f"Error loading model: {e}")
        exit()

# Preprocess the image for prediction
def preprocess_image(image_path, target_size=(224, 224)):
    if not os.path.exists(image_path):
        print(f"Image file not found: {image_path}")
        return None
    try:
        with Image.open(image_path) as img:
            img = img.convert("RGB").resize(target_size)
        return np.expand_dims(np.array(img) / 255.0, axis=0)
    except Exception as e:
        print(f"Error preprocessing image: {e}")
        return None

# Predict the class and confidence
def predict_class(image_path, model, class_names):
    image = preprocess_image(image_path)
    if image is not None:
        try:
            predictions = model.predict(image)
            predicted_index = np.argmax(predictions[0])
            return class_names[predicted_index], predictions[0][predicted_index]
        except Exception as e:
            print(f"Error during prediction: {e}")
    return None, None

# Main workflow
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Image classification using trained model.")
    parser.add_argument('image_path', type=str, help="Path to the image for prediction")
    args = parser.parse_args()

    MODEL_PATH = "Image_model/mobilenetv2_model.keras"
    IMAGE_PATH = args.image_path  # Get image path from command-line argument
    CLASS_NAMES = ['Normal', 'Fungi', 'Bacteria', 'Nematodes', 'Virus']

    model = load_trained_model(MODEL_PATH)
    predicted_class, confidence = predict_class(IMAGE_PATH, model, CLASS_NAMES)

    if predicted_class:
        print(f"Predicted Class: {predicted_class}")
        print(f"Confidence Score: {confidence:.2f}")
    else:
        print("Prediction failed. Please check the image or model.")
