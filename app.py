from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import google.generativeai as genai
import logging

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configure Gemini API
api_key = 'AIzaSyAfkvkuSv4qPmN12M-qTxxIAl3hIoz-H64'  # Replace with your actual API key
if not api_key:
    raise ValueError("API key not found. Please set it in your script.")

genai.configure(api_key=api_key)

# Load Gemini Model
model = genai.GenerativeModel(model_name='gemini-2.0-flash')

import concurrent.futures


def get_response(query):
    try:
        with concurrent.futures.ThreadPoolExecutor() as executor:
            future = executor.submit(model.generate_content, query)
            response = future.result(timeout=25)  # Fail if it takes more than 25 seconds
            return response.text
    except concurrent.futures.TimeoutError:
        logger.error("Gemini API call timed out.")
        return "Sorry, the server took too long to respond. Please try again."
    except Exception as e:
        logger.error(f"Error generating content: {e}")
        return f"An error occurred: {e}"



@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    if not data:
        logger.warning("No JSON data received")
        return jsonify({'response': 'No data provided'}), 400
    
    query = data.get('query', '')
    logger.info(f"Received query: {query}")
    
    if not query:
        return jsonify({'response': 'No query provided'}), 400
    
    if query.lower() == 'exit':
        return jsonify({'response': 'Goodbye!'}), 200
    
    response = get_response(query)
    logger.info(f"Generated response for query")
    return jsonify({'response': response}), 200

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'ok'}), 200

if __name__ == '__main__':
    # Listen on all network interfaces, making it accessible from mobile devices
    app.run(host='0.0.0.0', port=8000, debug=True)
  # Changed port to 8000
  