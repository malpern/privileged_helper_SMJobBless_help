#!/bin/bash

# Build script for SMJobBless implementation
set -e

PROJECT_DIR="$PWD"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="SMJobBlessApp"
HELPER_NAME="Helper"

echo "Building SMJobBless implementation manually..."

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the helper first
echo "Building helper..."
cd "$PROJECT_DIR"

swiftc \
    -target x86_64-apple-macosx15.2 \
    -sdk "$(xcrun --show-sdk-path)" \
    -o "$BUILD_DIR/$HELPER_NAME" \
    SMJobBlessApp/Helper/main.swift

echo "Helper built successfully"

# Build the main app
echo "Building main app..."

# Create app bundle structure
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
mkdir -p "$APP_BUNDLE/Contents/Library/LaunchServices"

# Copy helper into app bundle
cp "$BUILD_DIR/$HELPER_NAME" "$APP_BUNDLE/Contents/Library/LaunchServices/"

# Copy launchd.plist
cp SMJobBlessApp/Helper/launchd.plist "$APP_BUNDLE/Contents/Library/LaunchServices/"

# Build main app executable
swiftc \
    -target x86_64-apple-macosx15.2 \
    -sdk "$(xcrun --show-sdk-path)" \
    -framework SwiftUI \
    -framework ServiceManagement \
    -framework Security \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    SMJobBlessApp/SMJobBlessApp/SMJobBlessAppApp.swift \
    SMJobBlessApp/SMJobBlessApp/ContentView.swift

# Copy Info.plist
cp SMJobBlessApp/SMJobBlessApp/Info.plist "$APP_BUNDLE/Contents/"

echo "App built successfully at $APP_BUNDLE"
echo ""
echo "To test:"
echo "1. Open $APP_BUNDLE"
echo "2. Click 'Install Helper' to install the privileged helper"
echo "3. Click 'Test Helper' to communicate with the helper"
echo "4. Click 'Uninstall Helper' to remove the helper"