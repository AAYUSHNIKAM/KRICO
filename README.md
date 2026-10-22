# KRICO - Krida & Coach Sports Ecosystem Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50)](#platforms-supported)
[![State Management](https://img.shields.io/badge/State-Flutter%20Riverpod%20v3-blueviolet)](https://riverpod.dev)
[![Routing](https://img.shields.io/badge/Navigation-GoRouter-orange)](https://pub.dev/packages/go_router)

**KRICO** is an end-to-end, multi-role sports management and athlete empowerment platform. Built on Flutter and powered by Google Cloud & Firebase, KRICO seamlessly connects **Athletes (Players)**, **Coaches**, **Sports Academies**, **Parents**, and **Ecosystem Administrators** in a unified, high-performance digital environment.

---

## Table of Contents

- [Core Value Proposition](#core-value-proposition)
- [Multi-Role Architecture](#multi-role-architecture)
- [Key Features](#key-features)
- [Branching Strategy](#branching-strategy)
- [Technology Stack](#technology-stack)
- [Directory Structure](#directory-structure)
- [Getting Started & Setup](#getting-started--setup)
  - [Prerequisites](#prerequisites)
  - [Step 1: Clone Repository](#step-1-clone-repository)
  - [Step 2: Install Dependencies](#step-2-install-dependencies)
  - [Step 3: Firebase Configuration](#step-3-firebase-configuration)
  - [Step 4: Run Application](#step-4-run-application)
- [Building for Production](#building-for-production)
- [100% Free Web Hosting & Custom Domain Guide](#100-free-web-hosting--custom-domain-guide)
- [License & Contributions](#license--contributions)

---

## Core Value Proposition

- **Unified Sports Network**: Eliminates fragmented communication between coaches, venues, academies, and athletes.
- **Accredited Athlete Progression**: 15-tier progression system offering formal vector PDF certifications and shareable in-app medals with QR cryptographic verification.
- **Verified Escrow & Contracts**: Transparent fee structures (10% platform, 10% opportunity, 10% savings) with digital dual-party signing.
- **Responsive Omni-Platform**: Single codebase serving Android smartphones, iPhones, iPad/tablets, high-res web browsers, and desktop platforms.

---

## Multi-Role Architecture

KRICO provisions dedicated experiences for each stakeholder:

```
                      +-------------------+
                      |   KRICO ENGINE    |
                      +---------+---------+
                                |
       +------------+-----------+-----------+------------+
       |            |           |           |            |
+------v-----+ +----v----+ +----v----+ +----v-----+ +----v----+
|   PLAYER   | |  COACH  | | ACADEMY | |  PARENT  | |  ADMIN  |
|   PORTAL   | |   HUB   | | SYSTEM  | |  PORTAL  | | CONSOLE |
+------------+ +---------+ +---------+ +---------+ +---------+
```

1. **Player (Athlete)**:
   - Heads-Up Dashboard (HUD) with training streak, daily missions, progression milestones, and recent performance telemetry.
   - Coach and venue discovery with instant booking.
   - Interactive 15-tier milestone certificates with social sharing and official vector PDF export.
   - Video analysis with frame-by-frame coach feedback.

2. **Coach**:
   - Availability and session management with automated calendar clash avoidance.
   - Dynamic coaching packages, student rosters, and earnings analytics.
   - Digital contracts with transparent commission splits and signature flows.
   - Job opportunities board posted by accredited academies.

3. **Academy**:
   - Batch formation and schedule management with capacity tracking.
   - Staff recruitment (job posting, application review, coach contracts).
   - Advertising campaign creator and student enrollment tracking.

4. **Parent**:
   - Multi-child athlete performance monitoring (speed, stamina, accuracy, attendance).
   - Direct coach messaging and scheduled session approvals.
   - Secure payment and subscription management.

5. **Administrator**:
   - Platform-wide KPI counters (active users, total bookings, verified venues, platform revenue).
   - Venue database verification and approval.
   - Promotional coupon engine and role permission audits.

---

## Key Features

- **Decentralized Role Routing**: Instant switching between roles via `GoRouter` with state-preserving shells.
- **Milestone Registry**: 15 custom-crafted achievement tiers featuring luxury vector ornaments, verified stamps, and high-fidelity social image export.
- **Real-time Messaging**: Multi-channel in-app chat with attachment capabilities backed by Firestore.
- **Interactive Geospatial Search**: Google Maps integration for venue and turf discovery filtered by sport, distance, and ratings.
- **Interactive Telemetry**: High-performance charting (`fl_chart`) for athletic growth metrics over time.

---

## Branching Strategy

This repository follows a structured enterprise branching model:

| Branch | Purpose | Stability | Deployment Target |
|---|---|---|---|
| `master` | Production releases and tags | Highly Stable | Production Web & App Stores |
| `qa` | Staging, QA testing, integration validation | Pre-release | Staging / Beta TestFlight / Internal Testing |
| `dev` | Active development, feature merges, daily work | Experimental | Local Dev & Development builds |

### Typical Workflow

```bash
# 1. Start from dev
git checkout dev
git pull origin dev

# 2. Create your feature branch
git checkout -b feature/your-feature-name

# 3. Commit changes and merge back to dev
git commit -m "feat: Add new booking flow"
git push origin feature/your-feature-name

# 4. Promote from dev -> qa (for testing)
git checkout qa
git merge dev
git push origin qa

# 5. Promote from qa -> master (for production)
git checkout master
git merge qa
git push origin master
```

---

## Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (v3.22+)
- **Language**: [Dart](https://dart.dev) (v3.4+)
- **State Management**: [Riverpod 3.0](https://riverpod.dev)
- **Routing**: [GoRouter 17.0](https://pub.dev/packages/go_router)
- **Backend & Cloud**:
  - Firebase Authentication (Google Sign-In, Email/Password)
  - Cloud Firestore (Real-time NoSQL database)
  - Firebase Storage (Athlete documents, media, video captures)
  - Firebase Cloud Messaging (Push notifications)
- **UI & Graphics**:
  - Google Fonts (Roboto typography)
  - FL Chart (Analytics and metrics visualization)
  - Flutter Animate (Fluid micro-interactions and transitions)
  - Printing & PDF (Vector certificate rendering)
  - QR Flutter (Secure booking and accreditation verification)

---

## Directory Structure

```
KRICO/
â”œâ”€â”€ android/                  # Android native project and Gradle configuration
â”œâ”€â”€ ios/                      # iOS native project and CocoaPods configuration
â”œâ”€â”€ web/                      # Flutter web entrypoint, manifest, and icons
â”œâ”€â”€ assets/                   # Vector badges, logos, sport icons, and fonts
â”œâ”€â”€ certificates_showcase/    # 15 Milestone vector PDF and UI snapshot showcases
â”œâ”€â”€ docs/                     # Architectural specifications and audit documents
â”œâ”€â”€ lib/
â”‚   â”œâ”€â”€ core/                 # Constants, theme, routing, error helpers, utilities
â”‚   â”œâ”€â”€ design_system/        # Design tokens, color scheme, navigation layouts, buttons
â”‚   â”œâ”€â”€ features/             # Feature-driven modules
â”‚   â”‚   â”œâ”€â”€ academy/          # Academy batch management & dashboards
â”‚   â”‚   â”œâ”€â”€ admin/            # Platform administration console
â”‚   â”‚   â”œâ”€â”€ auth/             # Login, signup, password reset, and onboarding
â”‚   â”‚   â”œâ”€â”€ booking/          # Session booking, scheduling, and slot selection
â”‚   â”‚   â”œâ”€â”€ chat/             # Real-time chat list & detail views
â”‚   â”‚   â”œâ”€â”€ coach/            # Coach dashboard, availability, and profile
â”‚   â”‚   â”œâ”€â”€ home/             # Multi-role shells and navigation tabs
â”‚   â”‚   â”œâ”€â”€ player/           # Athlete dashboard, progression HUD, certificates
â”‚   â”‚   â”œâ”€â”€ squad_goals/      # Squad challenges and team milestones
â”‚   â”‚   â”œâ”€â”€ venue/            # Venue discovery and turf details
â”‚   â”‚   â””â”€â”€ video_analysis/   # Frame-by-frame video feedback
â”‚   â”œâ”€â”€ models/               # Domain data models with serialization
â”‚   â”œâ”€â”€ providers/            # Riverpod state providers
â”‚   â”œâ”€â”€ services/             # Firestore, Auth, PDF, and cloud services
â”‚   â””â”€â”€ main.dart             # Application root entrypoint
â”œâ”€â”€ test/                     # Unit and integration test suites
â”œâ”€â”€ .firebaserc               # Firebase project target configuration
â”œâ”€â”€ firebase.json             # Firebase hosting and index settings
â”œâ”€â”€ firestore.rules           # Cloud Firestore security rules
â”œâ”€â”€ storage.rules             # Firebase Storage security rules
â””â”€â”€ pubspec.yaml              # Project manifest and package dependencies
```

---

## Getting Started & Setup

### Prerequisites

Ensure you have installed:
1. **Flutter SDK** (Version `>=3.22.0`): Run `flutter doctor` to verify.
2. **Git**: Version control.
3. **Android Studio** or **VS Code** with Flutter and Dart extensions.
4. **Google Chrome** (for running and debugging the web application).
5. **Node.js & Firebase CLI** (optional, for deploying rules or hosting):
   ```bash
   npm install -g firebase-tools
   ```

---

### Step 1: Clone Repository

Clone your preferred branch:

```bash
# Clone the development branch
git clone -b dev https://github.com/AAYUSHNIKAM/KRICO.git

# Navigate into the project folder
cd KRICO
```

---

### Step 2: Install Dependencies

Fetch all Dart and Flutter packages:

```bash
flutter pub get
```

---

### Step 3: Firebase Configuration

KRICO uses Firebase for backend storage and authentication.

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com).
2. Configure FlutterFire using the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Enable **Email/Password** and **Google Sign-In** under Authentication.
4. Deploy the security rules and indexes included in the repository:
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```

---

### Step 4: Run Application

#### Run on Web (Chrome)
```bash
flutter run -d chrome
```

#### Run on Android Device / Emulator
```bash
flutter run -d android
```

#### Run on iOS Simulator (macOS only)
```bash
flutter run -d ios
```

#### Run Automated Test Suites
```bash
flutter test
```

---

## Building for Production

### Web Release Build
```bash
flutter build web --release
```
The optimized bundle will be generated in `build/web/`.

### Android APK / App Bundle
```bash
# Split-per-ABI APKs
flutter build apk --split-per-abi

# Production Google Play App Bundle
flutter build appbundle
```

---

## 100% Free Web Hosting & Custom Domain Guide

You can host the KRICO Flutter Web app at **$0.00 / month forever** using any of the following reliable services:

### Option 1: Firebase Hosting (Recommended - 100% Free)
Since KRICO already uses Firebase, Firebase Hosting offers:
- **Free domains provided**: `krico.web.app` and `krico.firebaseapp.com`
- Free SSL certificates, global SSD-backed CDN, and custom domain connection at no cost.

**How to Deploy**:
```bash
# 1. Build the production web bundle
flutter build web --release

# 2. Deploy to Firebase Hosting
firebase login
firebase deploy --only hosting
```

---

### Option 2: Cloudflare Pages (Free - Unlimited Bandwidth)
Cloudflare Pages provides blazing-fast edge performance with completely unmetered bandwidth:
- **Free subdomain provided**: `krico.pages.dev`
- Unlimited requests, automatic HTTPS, and direct GitHub repo auto-deployment.

**How to Setup**:
1. Sign up at [pages.cloudflare.com](https://pages.cloudflare.com) (free).
2. Connect your GitHub repository (`AAYUSHNIKAM/KRICO`).
3. Set the build command:
   ```bash
   flutter/bin/flutter build web --release
   ```
4. Set Output directory to: `build/web`
5. Cloudflare will publish it automatically at `https://krico.pages.dev` whenever you push to `master`.

---

### Option 3: GitHub Pages (100% Free via GitHub Actions)
Host directly inside GitHub with automatic CI/CD:
- **Free domain provided**: `https://aayushnikam.github.io/KRICO/`

**How to Setup**:
1. Push your code to the `master` branch.
2. In your repo, go to **Settings > Pages**.
3. Under **Build and deployment**, select **GitHub Actions**.
4. GitHub will build the Flutter web app and host it completely free.

---

### Getting a Free Developer Custom Domain (`krico.<domain>`)
If you want a free custom address like `krico.is-a.dev`:
- Visit [is-a.dev](https://is-a.dev/) (a free registry for developers).
- Fork their repository, add a `krico.json` CNAME pointing to your GitHub Pages or Cloudflare Pages URL.
- Once merged (usually 24 hours), your website will be live at `https://krico.is-a.dev` at zero cost!

---

## License & Contributions

Developed and maintained by **Aayush Nikam**.
All rights reserved. Community contributions and pull requests are welcomed across the `dev` branch.
