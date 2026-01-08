# Firebase Hosting for Cipher App (Flutter Web)

This guide covers enabling Flutter Web, building the app, configuring Firebase Hosting (including SPA rewrites and caching), local testing, deployments, preview channels, and CI/CD.

> Project structure note: your Flutter app lives at `cipher_app/`. The web build output is `cipher_app/build/web`, so the Hosting `public` directory must point there.

## 1) Prerequisites

- Firebase project created (e.g., `cipher-app-dev`, `cipher-app-prod`).
- Firebase CLI installed and authenticated.
- Flutter SDK installed and on stable channel.
- GitHub repository (if you want CI/CD).

```bash
# Install Firebase CLI (Node.js required)
npm i -g firebase-tools

# Authenticate
firebase login

# Verify Flutter
flutter --version
```

## 2) Enable Flutter Web and Build

```bash
# From repository root
cd cipher_app

# Ensure web support is enabled
flutter config --enable-web
flutter pub get

# Build release assets
flutter build web --release

# Output directory: cipher_app/build/web
```

## 3) Initialize/Configure Firebase Hosting

From the repository root (where `firebase.json` and `.firebaserc` live or will be created):

```bash
# If not initialized yet
firebase init hosting
# Choose: Use an existing project
# Public directory: cipher_app/build/web
# Configure as a single-page app (rewrite all URLs to /index.html): Yes
# Set up automatic builds and deploys with GitHub? Optional (you can add later)
```

If `firebase.json` already exists, ensure Hosting points to the Flutter web build and SPA rewrites are present.

### Example firebase.json

```json
{
  "hosting": {
    "public": "cipher_app/build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "/index.html",
        "headers": [
          { "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }
        ]
      },
      {
        "source": "**/*.{js,css,wasm}",
        "headers": [
          { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
        ]
      },
      {
        "source": "/assets/**",
        "headers": [
          { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
        ]
      },
      {
        "source": "**/*.{png,jpg,jpeg,gif,svg,webp,woff,woff2,ttf,otf}",
        "headers": [
          { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
        ]
      }
    ]
  }
}
```

### .firebaserc (multiple environments)

```json
{
  "projects": {
    "default": "cipher-app-dev",
    "prod": "cipher-app-prod"
  }
}
```

Switch projects:

```bash
# Link current directory to a project alias
firebase use --add

# Switch between linked projects
firebase use default
firebase use prod
```

## 4) Local Testing

```bash
# Serve built web assets (after build) from Hosting emulator
firebase emulators:start --only hosting
# Open http://localhost:5000
```

Alternatively, during development:

```bash
# Hot reload (no hosting emulator), served by Flutter
dart pub global activate webdev # only if needed for older toolchains
flutter run -d chrome
```

## 5) Deployments

Build, then deploy:

```bash
cd cipher_app
flutter build web --release
cd ..

# Deploy to currently selected project
firebase deploy --only hosting
```

### Preview Channels (recommended)

Preview channels let you share staged versions without affecting production.

```bash
# Create or update a preview channel and deploy to it
firebase hosting:channel:deploy preview-123
# URL will be printed (unique *.web.app domain)
```

You can create a channel per-PR or per-branch.

## 6) CI/CD (GitHub Actions)

Two common patterns:
- Deploy previews on pull requests.
- Deploy production on main or tagged releases.

Create `.github/workflows/hosting.yml` in repository root:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'

      - name: Install dependencies
        working-directory: cipher_app
        run: flutter pub get

      - name: Build web
        working-directory: cipher_app
        run: flutter build web --release

      - name: Install Firebase CLI
        run: npm i -g firebase-tools

      - name: Deploy preview (PR) / production (main)
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        run: |
          if [ "${{ github.event_name }}" = "pull_request" ]; then
            firebase hosting:channel:deploy pr-${{ github.event.number }} --project ${{ secrets.FIREBASE_PROJECT_ALIAS || 'default' }}
          else
            firebase deploy --only hosting --project ${{ secrets.FIREBASE_PROJECT_ALIAS || 'default' }}
          fi
```

Notes:
- Set `FIREBASE_TOKEN` in repo secrets: `firebase login:ci` to generate.
- Optionally set `FIREBASE_PROJECT_ALIAS` secret (`default`/`prod`). If omitted, `.firebaserc` default is used.

## 7) Environment Configuration

Use `flutterfire` to configure Firebase options (ensures web config is embedded).

```bash
# From repo root
flutter pub global activate flutterfire_cli
flutterfire configure \
  --project=cipher-app-dev \
  --out=cipher_app/lib/firebase_options.dart \
  --platforms=web,android,ios,macos,windows,linux
```

In your `main.dart`, ensure Firebase initialization uses `DefaultFirebaseOptions.currentPlatform` and that the web app has been added in the Firebase console (authorized domain present).

## 8) Storage CORS (if using Firebase Storage from web)

Set CORS for your bucket if you fetch blobs directly from the browser:

```json
[
  {
    "origin": ["https://*.web.app", "https://*.firebaseapp.com", "http://localhost:5000"],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600
  }
]
```

Apply with gsutil:

```bash
gsutil cors set cors.json gs://<your-bucket>
```

## 9) Best Practices

- SPA rewrite to `/index.html` so deep links work on refresh.
- Cache-bust immutable assets with long TTL; avoid caching `index.html`.
- Keep `flutter build web` in the deploy pipeline; do not commit `build/`.
- Use preview channels for reviews and QA.
- Monitor with Firebase Hosting logs and set up rollbacks (`firebase hosting:rollback`).

## 10) Troubleshooting

- 404 on refresh: missing SPA rewrite—add `{ "source": "**", "destination": "/index.html" }`.
- Stale UI after deploy: `index.html` cached—set `no-cache` header.
- Mixed-content errors: ensure all endpoints use HTTPS.
- Auth popup/redirect blocked: add your domain to Firebase Auth authorized domains.
- Fonts not loading: correct asset paths and MIME types; ensure they’re included in `pubspec.yaml`.

---

With this setup, `cipher_app/build/web` is served via Firebase Hosting with SPA-friendly routing, strong caching, and optional CI-driven preview/production deployments.
