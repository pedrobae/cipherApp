#!/bin/sh
# Xcode Cloud post-clone script for Flutter iOS builds
# Installs Flutter and dependencies, runs pub get and pod install

set -e

echo "Cleaning Flutter build artifacts..."
flutter clean

echo "Running flutter pub get..."
flutter pub get

echo "Installing iOS pods..."
cd ios
pod install --repo-update
cd ..

echo "Build preparation complete!"
exit 0
