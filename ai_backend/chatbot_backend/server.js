require("dotenv").config();

const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json({ limit: "100kb" }));

const PORT = Number(process.env.PORT) || 3000;

async function startServer() {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is missing from .env");
  }

  // Load the official Gemini SDK.
  const { GoogleGenAI } = await import("@google/genai");

  const ai = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY,
  });

  const systemPrompt = `
You are CodeAtlas AI, a helpful coding assistant.

Help developers:
- Understand their software projects.
- Learn Flutter and Dart step by step.
- Debug coding errors.
- Understand Java, Python, APIs and Git.
- Learn software architecture and project modules.

Give clear, beginner-friendly explanations and code examples.
Do not claim to have read files that were not provided.
`;

  app.get("/health", (req, res) => {
    res.json({ status: "ok" });
  });

  app.post("/api/chat", async (req, res) => {
    try {
      const { message, history = [] } = req.body;

      if (typeof message !== "string" || !message.trim()) {
        return res.status(400).json({
          error: "Please enter a message.",
        });
      }

      if (!Array.isArray(history)) {
        return res.status(400).json({
          error: "Invalid conversation history.",
        });
      }

      const contents = history
        .slice(-10)
        .filter(
          (item) =>
            item &&
            ["user", "assistant"].includes(item.role) &&
            typeof item.content === "string"
        )
        .map((item) => ({
          role: item.role === "assistant" ? "model" : "user",
          parts: [{ text: item.content.slice(0, 4000) }],
        }));

      // Add the latest user message.
      contents.push({
        role: "user",
        parts: [{ text: message.trim().slice(0, 4000) }],
      });

      const response = await ai.models.generateContent({
        // Use a model enabled for your account's free tier.
       model: "gemini-3.5-flash-lite",
        contents,
        config: {
          systemInstruction: systemPrompt,
          maxOutputTokens: 1000,
        },
      });

      const reply =
        response.text || "Sorry, I could not generate an answer.";

      res.json({ reply });
    } catch (error) {
      console.error(
        "Gemini API error:",
        error.message
      );

      res.status(500).json({
        error: "Gemini could not process your request. Check server logs.",
      });
    }
  });

  app.listen(PORT, "0.0.0.0", () => {
    console.log(
      `CodeAtlas Gemini backend listening on port ${PORT}`
    );
  });
}

startServer().catch((error) => {
  console.error("Backend startup failed:", error.message);
  process.exit(1);
});
