
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";

// --------------------------------------------------
// PATH CONFIGURATION
// --------------------------------------------------

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const ENV_PATH = path.join(__dirname, ".env");

// Load environment variables from this backend folder
dotenv.config({ path: ENV_PATH });

const projectRoot = process.env.PROJECT_ROOT
  ? path.resolve(process.env.PROJECT_ROOT)
  : path.resolve(__dirname, "../..");

// --------------------------------------------------
// GEMINI CONFIGURATION
// --------------------------------------------------

if (!process.env.GEMINI_API_KEY) {
  throw new Error("GEMINI_API_KEY is missing in .env file");
}

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY
});

// --------------------------------------------------
// FILE CONFIGURATION
// --------------------------------------------------

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
  ".pdf",
  ".gradle",
  ".properties",
  ".kt",
  ".sh"
];

// Directories that should not be indexed
const excludedDirectories = [
  "node_modules",
  ".git",
  ".dart_tool",
  "build",
  "dist",
  ".idea",
  ".vscode",
  ".gradle",
  ".firebase",
  "coverage",
  "Pods"
];

// Sensitive or unnecessary files
const excludedFiles = [
  ".env",
  "firebase_options.dart",
  "google-services.json",
  "GoogleService-Info.plist",
  "pubspec.lock",
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml"
];

// Files larger than this are skipped
const MAX_FILE_SIZE = 100 * 1024 * 1024;

// --------------------------------------------------
// CHECK SENSITIVE FILES
// --------------------------------------------------

function isExcludedFile(fileName) {
  const lowerName = fileName.toLowerCase();

  if (excludedFiles.includes(fileName)) {
    return true;
  }

  // Avoid service-account credentials and private keys
  if (
    lowerName.includes("service-account") ||
    lowerName.includes("service_account") ||
    lowerName.endsWith(".pem") ||
    lowerName.endsWith(".key") ||
    lowerName.endsWith(".p12") ||
    lowerName.endsWith(".pfx")
  ) {
    return true;
  }

  return false;
}

// --------------------------------------------------
// GET PROJECT FILES
// --------------------------------------------------

function getProjectFiles(directory) {
  let results = [];

  if (!fs.existsSync(directory)) {
    console.log("Directory not found, skipping:", directory);
    return results;
  }

  const entries = fs.readdirSync(directory, {
    withFileTypes: true
  });

  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      if (excludedDirectories.includes(entry.name)) {
        continue;
      }

      results.push(...getProjectFiles(fullPath));
    } else {
      const ext = path.extname(entry.name).toLowerCase();

      if (
        allowedExtensions.includes(ext) &&
        !isExcludedFile(entry.name) &&
        !entry.name.startsWith(".")
      ) {
        const stats = fs.statSync(fullPath);

        if (stats.size > MAX_FILE_SIZE) {
          console.log("Skipping large file:", entry.name);
          continue;
        }

        results.push(fullPath);
      }
    }
  }

  return results;
}

// --------------------------------------------------
// SAVE STORE NAME IN .ENV
// --------------------------------------------------

function saveStoreName(storeName) {
  let envContent = "";

  if (fs.existsSync(ENV_PATH)) {
    envContent = fs.readFileSync(ENV_PATH, "utf8");
  }

  const storeLine = `GEMINI_FILE_SEARCH_STORE=${storeName}`;

  if (/^GEMINI_FILE_SEARCH_STORE\s*=.*$/m.test(envContent)) {
    envContent = envContent.replace(
      /^GEMINI_FILE_SEARCH_STORE\s*=.*$/m,
      storeLine
    );
  } else {
    envContent += `\n${storeLine}\n`;
  }

  fs.writeFileSync(ENV_PATH, envContent, "utf8");

  // Update current process environment too
  process.env.GEMINI_FILE_SEARCH_STORE = storeName;
}

// --------------------------------------------------
// CREATE OR GET FILE SEARCH STORE
// --------------------------------------------------

async function getOrCreateStore() {
  let storeName = process.env.GEMINI_FILE_SEARCH_STORE;

  if (storeName && storeName.trim()) {
    console.log("Using existing File Search Store:", storeName);
    return storeName;
  }

  console.log("Creating new CodeAtlas File Search Store...");

  const store = await ai.fileSearchStores.create({
    config: {
      displayName: "codeatlas-knowledge",
      embeddingModel: "models/gemini-embedding-2"
    }
  });

  storeName = store.name;

  if (!storeName) {
    throw new Error("Gemini did not return a File Search Store name");
  }

  saveStoreName(storeName);

  console.log("File Search Store created:", storeName);

  return storeName;
}

// --------------------------------------------------
// INDEX PROJECT
// --------------------------------------------------

async function indexProject() {
  try {
    console.log("--------------------------------");
    console.log("CODEATLAS PROJECT INDEXING");
    console.log("--------------------------------");

    if (!fs.existsSync(projectRoot)) {
      throw new Error(
        "CodeAtlas project folder not found: " + projectRoot
      );
    }

    console.log("Project location:", projectRoot);

    // Create or reuse File Search Store
    const storeName = await getOrCreateStore();

    // --------------------------------------------------
    // SELECT PROJECT FILES
    // --------------------------------------------------

    console.log("\nSearching project files...");

    // Index the complete project tree, excluding
    // build folders, dependencies and sensitive files.
    const files = getProjectFiles(projectRoot);

    // Remove duplicate paths
    const uniqueFiles = [...new Set(files)];

    if (uniqueFiles.length === 0) {
      throw new Error("No supported project files found");
    }

    console.log("Total files found:", uniqueFiles.length);

    // --------------------------------------------------
    // UPLOAD FILES
    // --------------------------------------------------

    let successfulUploads = 0;
    let failedUploads = 0;

    for (const file of uniqueFiles) {
      const relativeName = path.relative(
        projectRoot,
        file
      ).replaceAll("\\", "/");

      try {
        console.log("\nUploading:", relativeName);

        let operation =
          await ai.fileSearchStores.uploadToFileSearchStore({
            file,
            fileSearchStoreName: storeName,
            config: {
              displayName: relativeName
            }
          });

        // Wait for Google to finish processing
        while (!operation.done) {
          await new Promise(resolve =>
            setTimeout(resolve, 5000)
          );

          operation = await ai.operations.get({
            operation
          });
        }

        if (operation.error) {
          throw new Error(JSON.stringify(operation.error));
        }

        successfulUploads++;

        console.log("Successfully indexed:", relativeName);

      } catch (error) {
        failedUploads++;

        console.error(
          "Failed to index:",
          relativeName,
          error.message
        );
      }
    }

    // --------------------------------------------------
    // FINAL RESULT
    // --------------------------------------------------

    console.log("\n--------------------------------");
    console.log("CODEATLAS INDEXING COMPLETED");
    console.log("--------------------------------");

    console.log("Total files:", uniqueFiles.length);
    console.log("Successful:", successfulUploads);
    console.log("Failed:", failedUploads);
    console.log("Store:", storeName);

    console.log("--------------------------------");

    if (failedUploads > 0) {
      console.log(
        "Some files were not indexed. Check the errors above."
      );
    }

  } catch (error) {
    console.error("\nINDEXING ERROR:", error);
    process.exitCode = 1;
  }
}

// Start indexing
indexProject();
