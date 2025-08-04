#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
RUST_TARGET="aarch64-linux-android"
OUTPUT_DIR="output"
APK_NAME="vieshare-release-aarch64.apk"
AAB_NAME="vieshare-release-aarch64.aab"
MANIFEST_PATH="/home/user/dev/vieshare_android/flutter/android/app/src/main/AndroidManifest.xml"
HOME_PAGE_PATH="/home/user/dev/vieshare_android/flutter/lib/mobile/pages/home_page.dart"


./flutter/ndk_arm64.sh


# Step 6: Build Rust library
echo "Building Rust library..."
# cargo ndk -t $RUST_TARGET --platform 21 build --release
LIB_DIR="./target/$RUST_TARGET/release"
# mkdir -p "android/app/src/main/jniLibs/arm64-v8a"
cp "$LIB_DIR/liblibvieshare.so" "./flutter/android/app/src/main/jniLibs/arm64-v8a/libvieshare.so"

# Step 7: Build Flutter APK
echo "Building Flutter APK..."
cd flutter
# flutter build apk --release --target-platform android-arm64
flutter build appbundle --target-platform  android-arm64,android-arm --release

# Step 8: Output APK
echo "Moving APK to output directory..."
# mkdir -p $OUTPUT_DIR
# mv build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_DIR/$APK_NAME"
mv build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/$AAB_NAME"

# /home/user/dev/vieshare-android/flutter/build/app/outputs/bundle/release/app-release.aab
# Finished
echo "Build complete. APK is located at $OUTPUT_DIR/$AA_NAME"
