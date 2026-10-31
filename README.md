# codeatlas

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# CodeAtlas – AI-Powered Developer Onboarding Platform

## 1. Project Overview

CodeAtlas, also known as OnboardAI, is an AI-powered
developer onboarding platform designed to simplify
the process of understanding existing software projects.

When a new developer joins a company, understanding an
existing codebase can be difficult and time-consuming.
Developers often need to read large amounts of documentation,
understand the architecture, explore source files and
identify how different modules work together.

CodeAtlas uses AI, document analysis and Retrieval
Augmented Generation (RAG) to make this process easier.

It provides project summaries, architecture explanations,
documentation summaries and an AI assistant that helps
developers understand the codebase and resolve programming
questions.

## 2. Problem Statement

New developers face difficulties when joining existing
software projects because:

- Project documentation can be lengthy.
- Understanding code architecture takes time.
- Developers may not know which files to explore.
- Finding the reason for existing errors is difficult.
- Learning project-specific workflows takes time.

## 3. Proposed Solution

CodeAtlas provides an AI-based onboarding platform that:

- Explains the purpose of the project.
- Summarizes project documentation.
- Helps developers explore project architecture.
- Answers questions about uploaded project files.
- Provides personalized learning paths.
- Helps developers understand and resolve coding errors.

## 4. Technology Stack

### Frontend
- Flutter
- Dart

### Backend
- Node.js
- Express.js
- Gemini API

### Database and Storage
- Firebase Authentication
- Cloud Firestore
- Supabase Storage

### AI Technologies
- Google Gemini
- Retrieval Augmented Generation (RAG)
- Gemini File Search

## 5. Main Features

### 5.1 AI Project Summary
Provides an overview of project objectives,
modules, technologies and workflows.

### 5.2 Architecture Explorer
Helps developers understand the project structure
and relationships between different modules.

### 5.3 Documentation Summarizer
Summarizes README files, PDFs and other
project documentation.

### 5.4 Ask OnboardAI
An AI assistant that answers project-related questions
using uploaded project documentation and source files.

### 5.5 Personalized Learning Path
Creates a learning plan based on the developer's
role and technical skills.

### 5.6 Known Issues Explorer
Helps developers understand documented project issues.

### 5.7 Developer Skill Matching
Matches developer skills with project requirements.

### 5.8 Progress Tracking
Tracks developer onboarding activities and progress.

## 6. Project Workflow

1. Developer joins the project.
2. Developer accesses project documentation.
3. AI analyzes the uploaded project knowledge.
4. Developer explores the project summary and architecture.
5. Developer asks questions using OnboardAI.
6. AI retrieves relevant project information.
7. Developer receives explanations and coding guidance.

## 7. Repository Structure

Explain the actual folders and important files here.

For example:

- lib/ – Flutter application source code.
- ai_backend/ – AI chatbot backend.
- docs/ – Developer and architecture documentation.
- pubspec.yaml – Flutter dependencies.
- README.md – Main project documentation.

Update this section using the actual repository structure.

## 8. Installation and Setup

### Requirements
- Flutter SDK
- Dart SDK
- Node.js and npm
- Android Studio or VS Code
- Firebase project
- Gemini API key

### Frontend Setup

Clone the repository:

    git clone YOUR_GITHUB_REPOSITORY_URL

Move into the project:

    cd codeatlas

Install Flutter packages:

    flutter pub get

Run the application:

    flutter run

### AI Backend Setup

Move into the chatbot backend directory:

    cd ai_backend/chatbot_backend

Install dependencies:

    npm install

Configure the .env file using the required environment
variables. Never commit API keys or credentials.

Start the backend:

    npm start

## 9. AI Chatbot Workflow

1. Developer enters a question.
2. Flutter sends the question to the Node.js backend.
3. Backend sends the question to Gemini.
4. Gemini File Search retrieves relevant project files.
5. Gemini generates an answer using retrieved context
   and its programming knowledge.
6. Backend returns the answer to Flutter.

## 10. Developer Guidelines

- Understand the existing architecture before modifying code.
- Follow the existing folder and naming conventions.
- Do not commit API keys or private credentials.
- Test changes before creating a pull request.
- Update documentation when adding new features.
