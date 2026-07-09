#!/bin/bash

echo "🚀 Building Kalpa Coffee App (Premium AOT + WebGL Caching)"

# Fail on error
set -e

echo "📦 1. Building Android APK (AOT Compiled, Impeller/Vulkan)"
# --release implies AOT compilation
flutter build apk --release --target-platform android-arm,android-arm64

echo "🌐 2. Building Web App (CanvasKit + Service Worker Caching)"
# --web-renderer canvaskit forces WebGL rendering for 120Hz/60Hz smooth animations
# Flutter web release builds automatically generate service workers for caching assets.
flutter build web --release --web-renderer canvaskit

echo "✅ Build complete! Binaries are in build/app/outputs/flutter-apk/ and build/web/"
