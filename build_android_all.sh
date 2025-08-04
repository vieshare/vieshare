#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
OUTPUT_DIR="output"
AAB_NAME="vieshare-release-universal.aab"

# Step 1: Build Rust library for arm64 (aarch64)
echo "=== Building Rust library for aarch64 ==="
RUST_TARGET="aarch64-linux-android"
./flutter/ndk_arm64.sh
# cargo ndk -t $RUST_TARGET --platform 21 build --release
cp "target/$RUST_TARGET/release/liblibvieshare.so" "./flutter/android/app/src/main/jniLibs/arm64-v8a/libvieshare.so"

# Step 2: Build Rust library for armv7
echo "=== Building Rust library for armv7 ==="
RUST_TARGET="armv7-linux-androideabi"
./flutter/ndk_arm.sh
# cargo ndk -t $RUST_TARGET --platform 21 build --release
cp "target/$RUST_TARGET/release/liblibvieshare.so" "./flutter/android/app/src/main/jniLibs/armeabi-v7a/libvieshare.so"

# Step 3: Build Flutter appbundle for both architectures
echo "=== Building Flutter AAB for arm64 and armv7 ==="
cd flutter
flutter build appbundle --target-platform android-arm,android-arm64 --release
cd ..

# Step 4: Move the AAB to output directory
echo "=== Moving output AAB to $OUTPUT_DIR ==="
mkdir -p "$OUTPUT_DIR"
mv flutter/build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/$AAB_NAME"

echo "✅ Build complete. AAB is located at $OUTPUT_DIR/$AAB_NAME"
