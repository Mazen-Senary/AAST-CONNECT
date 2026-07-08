# grad_project
# AAST Connect

AAST Connect is a cross-platform training and opportunities platform built as a Computer Science graduation project. The system helps students, fresh graduates, and administrators manage training opportunities, profiles, documents, training-hour progress, notifications, and AI-assisted support from one connected platform.

## Why this project exists

Students and fresh graduates often need to manage training requirements, documents, opportunities, and communication across disconnected channels. AAST Connect brings these workflows into one structured application with role-based access for students, fresh graduates, and administrators.

## Main roles

- **Student:** manages profile, documents, training submissions, training-hours progress, and opportunities.
- **Fresh Graduate:** browses opportunities, manages profile, receives notifications, and uses support features.
- **Admin:** reviews training-hour submissions, tracks student progress, manages data, and supports platform workflows.

## Key features

- Role-based authentication and navigation
- Student and fresh-graduate profile management
- CV/certificate/document upload and management
- Opportunity browsing with search and filters
- Training-hours tracking with pending, approved, and rejected states
- Admin review workflows for student submissions
- Real-time notifications using Supabase Realtime
- AI-powered chatbot using Google Gemini API and contextual application data
- Supabase-backed database, storage, and RPC functions
- Separate admin deployment using Firebase Hosting

## Tech stack

### Frontend
- Flutter
- Dart
- Material Design
- Provider / app state management
- Responsive mobile UI

### Backend and data
- Supabase
- PostgreSQL
- Supabase Authentication
- Supabase Storage
- Supabase Realtime
- PostgreSQL RPC functions

### AI integration
- Google Gemini API
- Contextual prompt construction from application data

### Tools
- Git and GitHub
- Android Studio / VS Code
- Firebase Hosting for admin deployment
