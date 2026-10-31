
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { GoogleGenAI } from "@google/genai";

// --------------------------------------------------
// ENVIRONMENT CONFIGURATION
// --------------------------------------------------

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({
  path: path.join(__dirname, ".env")
});

const app = express();

const PORT = process.env.PORT || 3000;

const MODEL =
  process.env.GEMINI_MODEL || "gemini-3.5-flash-lite";

const API_KEY = process.env.GEMINI_API_KEY;

const STORE_NAME = process.env.GEMINI_FILE_SEARCH_STORE;

// --------------------------------------------------
// VALIDATE CONFIGURATION
// --------------------------------------------------

if (!API_KEY) {
  throw new Error("GEMINI_API_KEY is missing in .env file");
}

if (!STORE_NAME) {
  throw new Error(
    "GEMINI_FILE_SEARCH_STORE is missing. Run node index-project.js first."
  );
}

// --------------------------------------------------
// INITIALIZE GEMINI
// --------------------------------------------------

const ai = new GoogleGenAI({
  apiKey: API_KEY
});

// --------------------------------------------------
// MIDDLEWARE
// --------------------------------------------------

app.use(cors({
  origin: true,
  methods: ["GET", "POST", "OPTIONS"],
  allowedHeaders: ["Content-Type"]
}));

app.use(express.json({
  limit: "2mb"
}));

// --------------------------------------------------
// CODEATLAS AI INSTRUCTIONS
// --------------------------------------------------

const projectKnowledge = `
You are CodeAtlas AI, an intelligent developer onboarding
and programming assistant.

YOUR MAIN PURPOSE:

Help new developers understand the CodeAtlas project,
learn its architecture, explore source code and resolve
programming errors.

PROJECT NAME:
CodeAtlas / OnboardAI

PROJECT DESCRIPTION:

CodeAtlas is an AI-powered developer onboarding platform.

It helps developers understand existing software projects
without manually reading large amounts of documentation.

It uses AI, document analysis and Retrieval Augmented
Generation (RAG) to simplify developer onboarding.

TECHNOLOGIES:

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Supabase Storage
- Node.js
- Express.js
- Google Gemini API
- Gemini File Search
- Retrieval Augmented Generation (RAG)

MAIN FEATURES:

1. AI Project Summary:
Explains project purpose, modules, technologies and users.

2. Architecture Explorer:
Helps developers understand the project architecture
and relationships between different modules.

3. Documentation Summarizer:
Summarizes README files, PDFs and project documentation.

4. Ask OnboardAI:
Answers project-specific questions using uploaded
project documentation and source files.

5. Personalized Learning Path:
Creates a day-wise onboarding plan based on developer
role and technical skills.

6. Known Issues Explorer:
Helps developers understand documented project issues.

7. Developer Skill Matching:
Matches developer skills with project requirements.

8. Progress Tracking:
Tracks developer onboarding activities and progress.

PROJECT WORKFLOW:

Project Documents and Source Files
-> AI Analysis
-> Project Summary and Architecture
-> Documentation and Tasks
-> Personalized Developer Onboarding.

YOUR RESPONSIBILITIES:

1. Use Gemini File Search to retrieve relevant CodeAtlas
   project information when answering project questions.

2. Explain the purpose of project files and folders.

3. Help developers understand Flutter widgets,
   Dart classes, functions and application workflows.

4. Explain how Firebase Authentication and Firestore
   are used when relevant source information is available.

5. Explain how the frontend communicates with the backend.

6. Resolve Flutter, Dart, Java, Python, SQL, JavaScript
   and other programming errors.

7. When a developer shares an error, explain:

   - What the error means.
   - Why the error occurs.
   - Which file or code section may need modification.
   - The corrected code.
   - How to test the solution.

8. Answer general programming questions even when
   they are unrelated to CodeAtlas.

9. Use simple, beginner-friendly language.

10. Format programming code using Markdown code blocks.

11. Do not invent project files, functions, APIs,
    database fields or features.

12. If the uploaded project files do not contain the
    required information, clearly mention that.

13. Distinguish between confirmed project information
    and general programming suggestions.

14. Never claim that you executed, compiled or tested
    code unless an actual execution tool was used.
`;

// --------------------------------------------------
// HOME ROUTE
// --------------------------------------------------

app.get("/", (req, res) => {
  res.send("CodeAtlas AI Backend is running!");
});

// --------------------------------------------------
// HEALTH CHECK
// --------------------------------------------------

app.get("/health", (req, res) => {
  res.json({
    status: "success",
    message: "CodeAtlas AI is ready",
    model: MODEL,
    fileSearch: true
  });
});

// --------------------------------------------------
// CHAT API
// --------------------------------------------------

app.post("/api/chat", async (req, res) => {
  try {
    const { message } = req.body;

    // Validate user message
    if (
      !message ||
      typeof message !== "string" ||
      !message.trim()
    ) {
      return res.status(400).json({
        error: "Please enter a message"
      });
    }

    console.log("\n--------------------------------");
    console.log("New CodeAtlas AI Question");
    console.log("--------------------------------");

    console.log("Question:", message);
    console.log("Model:", MODEL);
    console.log("Searching project knowledge...");

    // --------------------------------------------------
    // GEMINI FILE SEARCH REQUEST
    // --------------------------------------------------

    const response = await ai.interactions.create({
      model: MODEL,

      input: `${projectKnowledge}

Use the connected CodeAtlas File Search Store to
retrieve relevant project information.

For project-specific questions:
- Search relevant documentation and source files.
- Use the retrieved information in your explanation.
- Mention actual file paths when available.
- Do not guess when information is missing.

For general programming questions:
- Use your programming knowledge.
- Explain the solution step by step.
- Provide corrected code where necessary.

DEVELOPER QUESTION:
${message}`,

      tools: [
        {
          type: "file_search",
          file_search_store_names: [STORE_NAME]
        }
      ]
    });

    // --------------------------------------------------
    // EXTRACT GEMINI RESPONSE
    // --------------------------------------------------

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

    if (!reply.trim()) {
      reply =
        "Sorry, I could not generate an answer. Please try again.";
    }

    console.log("Gemini response received successfully");
    console.log("--------------------------------\n");

    // --------------------------------------------------
    // SEND RESPONSE TO FLUTTER
    // --------------------------------------------------

    return res.json({
      reply: reply
    });

  } catch (error) {
    console.error("\nGEMINI API ERROR:");
    console.error(error);

    return res.status(500).json({
      error: error.message || "Gemini API request failed"
    });
  }
});

// --------------------------------------------------
// START SERVER
// --------------------------------------------------

app.listen(PORT, "0.0.0.0", () => {
  console.log("--------------------------------");
  console.log("CODEATLAS AI BACKEND STARTED");
  console.log("--------------------------------");

  console.log("Project Knowledge: Loaded");
  console.log("Gemini File Search: Enabled");
  console.log("Model:", MODEL);
  console.log("Store:", STORE_NAME);
  console.log("Port:", PORT);

  console.log("--------------------------------");
});
