#!/bin/sh
# Xcode Cloud post-clone script for Flutter iOS builds
# Installs Flutter and dependencies, runs pub get and pod install

set -e

# Check if Flutter is installed, if not install it
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    export PATH="$PATH:$HOME/flutter/bin"
    flutter config --no-analytics
fi

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
