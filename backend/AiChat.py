
import os
from flask import request, jsonify
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

# Load Gemini API key securely from .env
gemini_key = os.getenv("GEMINI_API_KEY")

if not gemini_key:
    raise ValueError("GEMINI_API_KEY is missing from environment variables")

genai.configure(api_key=gemini_key)

model = genai.GenerativeModel("gemini-3.5-flash")


def ai_chat():
    data = request.json or {}
    message = data.get("message", "")

    try:
        prompt = f"""
        You are MedAI.

        Answer only healthcare, wellness,
        nutrition, fitness, mental health,
        and medical education questions.

        If the question is not related to health,
        reply:

        'I am a healthcare assistant.
        Please ask health-related questions.'

        User Question:
        {message}
        """

        response = model.generate_content(prompt)

        return jsonify({
            "success": True,
            "reply": response.text
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
