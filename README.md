A mobile chatbot app where students can ask questions and get instant answers using Google’s Gemini 2.0 Flash model.

🛠️ Tech Stack
Frontend: Flutter (main.dart)

Backend: Python Flask (app.py)

AI Model: Gemini 2.0 Flash (Google AI Studio)

Database: SQLite (stores chat history)

How It Works
Students type their questions in the Flutter app.

The app sends the question to the Flask backend.

The backend forwards the question to Gemini 2.0 Flash API.

Gemini responds with an answer.

The backend sends the answer back to the Flutter app.

Both the question and answer are stored in SQLite.

Project Structure
bash
Copy
Edit
/main.dart        # Flutter frontend
/app.py           # Flask server + Gemini API integration
/database.py      # Handles SQLite database
/main.py          # (Optional) Other backend logic if needed
Snapshots
(Add screenshots of your app and chatbot here.)

Setup
Clone the repo.

Add your Gemini API key in app.py.

Run app.py to start the Flask server.

Launch the Flutter app.

