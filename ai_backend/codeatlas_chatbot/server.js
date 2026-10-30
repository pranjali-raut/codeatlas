
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";

dotenv.config();

const app = express();

// Middleware
app.use(cors({
  origin: true,
  methods: ["GET", "POST", "OPTIONS"],
  allowedHeaders: ["Content-Type"]
}));

app.use(express.json());

// Environment variables
const PORT = process.env.PORT || 3000;
const MODEL = process.env.GEMINI_MODEL || "gemini-3.5-flash-lite";
const API_KEY = process.env.GEMINI_API_KEY;
const STORE_NAME = process.env.GEMINI_FILE_SEARCH_STORE;

// Check API key
if (!API_KEY) {
  throw new Error("GEMINI_API_KEY is missing in .env file");
}

// Check File Search Store
if (!STORE_NAME) {
  throw new Error(
    "GEMINI_FILE_SEARCH_STORE is missing. Run node index-project.js first."
  );
}

// Initialize Gemini
const ai = new GoogleGenAI({
  apiKey: API_KEY
});

// CodeAtlas project knowledge
const projectKnowledge = `
You are CodeAtlas AI Assistant, an intelligent programming
and developer onboarding assistant.

PROJECT NAME:
CodeAtlas / OnboardAI

PROJECT DESCRIPTION:
CodeAtlas is an AI-powered developer onboarding platform.
It helps new developers understand existing software projects
without manually reading large amounts of documentation.

TECHNOLOGIES:
- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Supabase Storage
- Gemini API
- Retrieval Augmented Generation (RAG)

MAIN FEATURES:

1. AI Project Summary:
Explains project purpose, modules, technologies and users.

2. Architecture Explorer:
Helps developers understand project architecture and modules.

3. Documentation Summarizer:
Summarizes README files, PDFs and project documentation.

4. Ask OnboardAI:
Answers project-related questions using project knowledge.

5. Personalized Learning Path:
Creates a day-wise onboarding plan based on developer role
and skills.

6. Known Issues Explorer:
Helps developers understand known project issues.

7. Developer Skill Matching:
Matches developer skills with project requirements.

8. Progress Tracking:
Tracks developer onboarding progress.

PROJECT WORKFLOW:
Project Documents / README / API Documentation
-> AI Analysis
-> Project Summary and Architecture
-> Documentation and Tasks
-> Personalized Developer Onboarding.

YOUR RESPONSIBILITIES:

1. Answer questions about CodeAtlas using uploaded project files.
2. Explain project features in simple language.
3. Resolve Flutter, Dart, Java, Python, SQL, JavaScript
   and other programming errors.
4. When users paste an error, explain:
   - What the error means.
   - Why it happens.
   - Which code needs to be changed.
   - Give corrected code.
   - Explain how to test the solution.
5. Answer general programming questions too.
6. Never invent CodeAtlas features or claim to have inspected
   source files that were not uploaded.
7. Give beginner-friendly, step-by-step answers.
8. Format code using proper Markdown code blocks.
9. If project information is not found in uploaded files,
   clearly say so instead of guessing.
`;

// Home route
app.get("/", (req, res) => {
  res.send("CodeAtlas AI Backend is running!");
});

// Health check
app.get("/health", (req, res) => {
  res.json({
    status: "success",
    message: "CodeAtlas AI is ready",
    model: MODEL,
    fileSearch: true
  });
});

// Chat API with Gemini File Search
app.post("/api/chat", async (req, res) => {
  try {
    const { message } = req.body;

    // Validate message
    if (!message || typeof message !== "string" || !message.trim()) {
      return res.status(400).json({
        error: "Please enter a message"
      });
    }

    console.log("--------------------------------");
    console.log("User question:", message);
    console.log("Using model:", MODEL);
    console.log("Searching CodeAtlas project files...");

    // Send question to Gemini with File Search
    const response = await ai.interactions.create({
      model: MODEL,

      input: `${projectKnowledge}

IMPORTANT:
Use File Search to retrieve relevant information from the
uploaded CodeAtlas project files when answering project questions.

For general programming questions, use your programming knowledge.

Give clear, beginner-friendly answers.
Provide complete corrected code when required.

USER QUESTION:
${message}`,

      tools: [
        {
          type: "file_search",
          file_search_store_names: [STORE_NAME]
        }
      ]
    });

    // Extract Gemini response
    let reply = "";

    for (const step of response.steps || []) {
      if (step.type === "model_output") {
        for (const block of step.content || []) {
          if (block.type === "text") {
            reply += block.text;
          }
        }
      }
    }

    // Fallback response
    if (!reply && response.outputText) {
      reply = response.outputText;
    }

    if (!reply) {
      reply = "Sorry, I could not generate an answer. Please try again.";
    }

    console.log("Gemini response received successfully");
    console.log("--------------------------------");

    // Send answer to Flutter
    res.json({
      reply: reply
    });

  } catch (error) {
    console.error("Gemini Error:", error);

    res.status(500).json({
      error: error.message || "Gemini API request failed"
    });
  }
});

// Start server
app.listen(PORT, "0.0.0.0", () => {
  console.log("--------------------------------");
  console.log("CodeAtlas AI Backend Started");
  console.log("Project Knowledge Loaded");
  console.log("Gemini File Search Enabled");
  console.log("Model:", MODEL);
  console.log("Server running on port", PORT);
  console.log("--------------------------------");
});
