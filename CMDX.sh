#!/bin/bash

# --- Variables ---
PROJECT_NAME="SystemInfo"
DYLIB_NAME="CMDX.dylib" # Changed dylib name
DEB_PACKAGE="$PROJECT_NAME.deb"
TWEAK_DIR="tmp_tweak" # Temporary directory to build the tweak structure
LOGOS_OUTPUT="Tweak.x.m" # Output file after Logos processing
ENTITLEMENTS="entitlements.plist" # Path to your entitlements file
P12_FILE="BDG.p12" # Path to your .p12 file
P12_PASSWORD="BDG" # Password for your .p12 file (if any)
KEYCHAIN_NAME="BDG" # Name for the temporary keychain

# --- Create a temporary keychain ---
security create-keychain -p temp "$KEYCHAIN_NAME"
security unlock-keychain "$KEYCHAIN_NAME"

# --- Import the .p12 certificate into the keychain ---
security import "$P12_FILE" -k "$KEYCHAIN_NAME" -P "$P12_PASSWORD" -T /usr/bin/codesign

# --- Set keychain as default ---
security default-keychain -s "$KEYCHAIN_NAME"

# --- Logos Processing ---

# Process Tweak.x with Logos
Logos Tweak.xm > $LOGOS_OUTPUT

# --- Compilation ---

# Compile Swift files into a dynamic library
swiftc -target arm64-apple-ios14.0 \
    -emit-library \
    CPUInfoProvider.swift \
    MemoryInfoProvider.swift \
    InfoWindow.swift \
    FloatingButton.swift \
    SystemInfo.swift \
    $LOGOS_OUTPUT \
    -o $DYLIB_NAME \
    -framework UIKit \
    -framework Foundation \
    -framework CoreGraphics

# --- Tweak Packaging ---

# Create the tweak directory structure
mkdir -p "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries"
mkdir -p "$TWEAK_DIR/DEBIAN"

# Copy the dynamic library
cp "$DYLIB_NAME" "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries/$DYLIB_NAME"

# Copy the control file
cp control "$TWEAK_DIR/DEBIAN/control"

# Create a dummy Tweak.x (or copy the original)
# This is needed for dpkg-deb, even though the actual logic is in the dylib
cp Tweak.x "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries/Tweak.x"

# Create the .deb package
dpkg-deb -b "$TWEAK_DIR" "$DEB_PACKAGE"

# --- Code Signing ---

# Unlock Keychain (if needed) and Sign the dylib with ldid
# This assumes your certificate from the p12 is added to the keychain
security unlock-keychain "$KEYCHAIN_NAME"

# Sign the dylib with ldid
ldid -s "$ENTITLEMENTS" "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries/$DYLIB_NAME"

# --- Remove the temporary keychain ---
security delete-keychain "$KEYCHAIN_NAME"

echo "Build complete. Output: $DEB_PACKAGE"