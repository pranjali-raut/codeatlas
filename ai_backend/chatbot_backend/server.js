
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY
});

const projectInfo = `
You are CodeAtlas AI, an assistant for the CodeAtlas project.

PROJECT NAME:
CodeAtlas - AI Powered Developer Onboarding Platform.

PROJECT DESCRIPTION:
CodeAtlas helps new developers understand existing software
projects without manually reading large amounts of documentation.

TECHNOLOGIES:
Flutter, Dart, Firebase Authentication, Cloud Firestore,
Supabase Storage, Node.js, Gemini API and RAG.

MAIN FEATURES:
1. AI Project Summary
2. Architecture Explorer
3. Documentation Summarizer
4. Ask OnboardAI Chatbot
5. Personalized Learning Path
6. Known Issues Explorer
7. Developer Skill Matching
8. Developer Progress Tracking

MAIN WORKFLOW:
Project documents and README are analyzed by AI.
The system generates project summaries, architecture details,
documentation and personalized developer learning paths.

YOUR RESPONSIBILITIES:
- Answer questions about CodeAtlas.
- Explain project features and architecture.
- Help developers understand Flutter and Dart.
- Find coding errors and explain their solutions.
- Provide corrected code when code is supplied.
- Explain answers in simple beginner-friendly language.
- If information is not provided, do not invent it.
`;

app.get("/", (req, res) => {
  res.send("CodeAtlas AI Backend is running!");
});

app.post("/api/chat", async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({
        error: "Please enter a message."
      });
    }

    const response = await ai.models.generateContent({
      model: "gemini-flash-latest",
      contents: `
        ${projectInfo}

        DEVELOPER QUESTION:
        ${message}

        Give a clear, useful answer.
        For coding errors, explain the cause and provide corrected code.
      `
    });

    res.json({
      reply: response.text || "No response generated."
    });

  } catch (error) {
    console.error("Gemini Error:", error);

    res.status(500).json({
      error: error.message || "Unable to generate response."
    });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log("--------------------------------");
  console.log("CodeAtlas AI Backend Started");
  console.log("Project Knowledge Loaded");
  console.log(`Server running on port ${PORT}`);
  console.log("--------------------------------");
});
