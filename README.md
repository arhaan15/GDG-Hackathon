📱 Student Chatbot App with Gemini AI
A mobile chatbot app where students can ask questions and get instant answers using Google’s Gemini 2.0 Flash model.

🛠️ Tech Stack
Frontend: Flutter (main.dart)

Backend: Python Flask (app.py)

AI Model: Gemini 2.0 Flash (Google AI Studio)

Database: SQLite (stores chat history)

🌐 Architecture
Flutter app sends user queries to the Flask server.

Flask server processes the request and calls Gemini API.

Gemini API responds with the answer.

Server sends the response back to Flutter app.

Chat history (questions and answers) is stored in SQLite.

📂 Project Structure
bash
Copy
Edit
/main.dart        # Flutter frontend (UI and API calls)
/app.py           # Flask server and Gemini API integration
/database.py      # SQLite database handling
/main.py          # Additional backend logic (if used)
⚙️ Setup Instructions
1. Clone the repository
bash
Copy
Edit
git clone https://github.com/your-username/your-repo-name.git
2. Install Python dependencies
bash
Copy
Edit
pip install flask flask-cors google-generativeai
3. Set up Gemini API Key
Get your API key from Google AI Studio.

Add it in app.py:

python
Copy
Edit
genai.configure(api_key="YOUR_API_KEY")
4. Run the Flask server
bash
Copy
Edit
python app.py
5. Run the Flutter app
bash
Copy
Edit
flutter run
