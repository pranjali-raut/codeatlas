
import fs from "node:fs";
import path from "node:path";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";

dotenv.config();

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY
});

// Your actual CodeAtlas project folder
const projectRoot =
  process.env.PROJECT_ROOT ||
  path.resolve(process.cwd(), "../..");

// Files and folders to include
const allowedExtensions = [
  ".dart",
  ".md",
  ".txt",
  ".json",
  ".yaml",
  ".yml",
  ".sql",
  ".js",
  ".ts",
  ".html",
  ".css",
  ".java",
  ".py",
  ".xml",
  ".pdf"
];

const excludedDirectories = [
  "node_modules",
  ".git",
  ".dart_tool",
  "build",
  "dist",
  ".idea",
  ".vscode",
  "android",
  "ios"
];

const excludedFiles = [
  ".env",
  "firebase_options.dart",
  "google-services.json",
  "pubspec.lock"
];

function getProjectFiles(directory) {
  let results = [];

  const entries = fs.readdirSync(directory, {
    withFileTypes: true
  });

  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      if (excludedDirectories.includes(entry.name)) {
        continue;
      }

      results = results.concat(
        getProjectFiles(fullPath)
      );
    } else {
      const ext = path.extname(entry.name).toLowerCase();

      if (
        allowedExtensions.includes(ext) &&
        !excludedFiles.includes(entry.name) &&
        !entry.name.startsWith(".")
      ) {
        results.push(fullPath);
      }
    }
  }

  return results;
}

async function indexProject() {
  try {
    if (!process.env.GEMINI_API_KEY) {
      throw new Error("Gemini API key is missing");
    }

    if (!fs.existsSync(projectRoot)) {
      throw new Error(
        "CodeAtlas project folder not found: " + projectRoot
      );
    }

    console.log("Creating CodeAtlas knowledge store...");

    let storeName = process.env.GEMINI_FILE_SEARCH_STORE;

    // Create store only once
    if (!storeName) {
      const store = await ai.fileSearchStores.create({
        config: {
          displayName: "codeatlas-knowledge",
          embeddingModel: "models/gemini-embedding-2"
        }
      });

      storeName = store.name;

      fs.appendFileSync(
        ".env",
        `\nGEMINI_FILE_SEARCH_STORE=${storeName}\n`
      );

      console.log("Knowledge store created:", storeName);
    } else {
      console.log("Using existing store:", storeName);
    }

    // Select source files
    const files = [
      ...getProjectFiles(path.join(projectRoot, "lib"))
    ];

    // Include useful root documentation
    for (const file of [
      "README.md",
      "pubspec.yaml",
      "analysis_options.yaml"
    ]) {
      const fullPath = path.join(projectRoot, file);

      if (fs.existsSync(fullPath)) {
        files.push(fullPath);
      }
    }

    console.log(`Found ${files.length} project files`);

    for (const file of files) {
      const relativeName = path.relative(
        projectRoot,
        file
      ).replaceAll("\\", "/");

      console.log("Uploading:", relativeName);

      let operation =
        await ai.fileSearchStores.uploadToFileSearchStore({
          file,
          fileSearchStoreName: storeName,
          config: {
            displayName: relativeName
          }
        });

      // Wait until Google finishes indexing
      while (!operation.done) {
        await new Promise(resolve =>
          setTimeout(resolve, 5000)
        );

        operation = await ai.operations.get({
          operation
        });
      }

      console.log("Indexed:", relativeName);
    }

    console.log("--------------------------------");
    console.log("CodeAtlas project indexing complete!");
    console.log("Total files:", files.length);
    console.log("Store:", storeName);
    console.log("--------------------------------");

  } catch (error) {
    console.error("Indexing error:", error);
    process.exitCode = 1;
  }
}

indexProject();
