#!/bin/bash
# SportsEco Firebase Setup Script
# Run this script to configure Firebase for your project.

echo "================================================"
echo "  SportsEco - Firebase Setup"
echo "================================================"
echo ""
echo "This script will help you set up Firebase for SportsEco."
echo ""

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null; then
    echo "Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "ERROR: Firebase CLI is not installed."
    echo "Install it from: https://firebase.google.com/docs/cli"
    echo "Then run: firebase login"
    exit 1
fi

# Login to Firebase (if needed)
echo "Logging into Firebase..."
firebase login --no-localhost

# Initialize Firebase project
echo ""
echo "Choose an option:"
echo "1) Use existing Firebase project"
echo "2) Create new Firebase project"
read -p "Enter choice (1 or 2): " choice

if [ "$choice" = "2" ]; then
    read -p "Enter a name for your new Firebase project: " project_name
    firebase projects:create "$project_name"
    project_id="$project_name"
else
    read -p "Enter your Firebase project ID: " project_id
fi

# Enable required Firebase services
echo "Enabling required Firebase services..."
firebase firestore:databases:create --project="$project_id" --location=asia-south1 2>/dev/null || echo "Firestore database may already exist"
firebase storage:create --project="$project_id" 2>/dev/null || echo "Storage bucket may already exist"

# Enable Authentication providers
echo "Enabling Email/Password authentication..."
firebase auth:enable:sign-in-provider email-password --project="$project_id" 2>/dev/null || echo "Auth may already be configured"

# Generate FlutterFire config
echo "Generating FlutterFire configuration..."
cd "$(dirname "$0")"
flutterfire configure --project="$project_id" --yes

echo ""
echo "================================================"
echo "  Firebase Setup Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Update 'lib/firebase_options.dart' if not already done"
echo "2. Run 'flutter pub get' to install dependencies"
echo "3. Run 'flutter run' to start the app"
echo ""
echo "Required Firestore indexes will be created on first use."
echo "For production, deploy Firestore indexes using:"
echo "  firebase deploy --only firestore:indexes"
