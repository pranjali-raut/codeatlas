import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT) || 3000;

app.use(cors());
app.use(express.json({ limit: "1mb" }));

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  console.error("GEMINI_API_KEY is missing. Check your .env file.");
  process.exit(1);
}

const ai = new GoogleGenAI({ apiKey });

app.post("/api/chat", async (req, res) => {
  const message = req.body?.message;

  if (typeof message !== "string" || !message.trim()) {
    return res.status(400).json({ error: "Please enter a message." });
  }

  try {
    // Use the model string requested by your error logs (e.g., "gemini-3.8-flash" or "gemini-2.5-flash")
    const response = await ai.models.generateContent({
      model: "gemini-3.8-flash", 
      contents: message.trim(),
    });

    const reply = response.text;

    if (!reply) {
      return res.status(502).json({ error: "Empty response from Gemini." });
    }

    return res.status(200).json({ reply: reply.trim() });
  } catch (error) {
    console.error("Gemini API error:", error?.message || error);
    return res.status(500).json({ error: error?.message || "Internal Server Error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});