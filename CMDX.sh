#!/bin/bash

# --- Variables ---
PROJECT_NAME="SystemInfo"
DYLIB_NAME="CMDX.dylib"
DEB_PACKAGE="$PROJECT_NAME.deb"
TWEAK_DIR="tmp_tweak"
LOGOS_OUTPUT="Tweak.x.m"
ENTITLEMENTS="entitlements.plist"
P12_FILE="BDG.p12"
P12_PASSWORD="AppleP12.com"
KEYCHAIN_NAME="BDG"

# --- Functions ---
function check_command {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "Command $1 not found. Please install it."; exit 1; }
}

# --- Check for necessary commands ---
check_command security
check_command swiftc
check_command dpkg-deb
check_command ldid
check_command Logos

# --- Create a temporary keychain ---
security create-keychain -p temp "$KEYCHAIN_NAME"
security unlock-keychain -p temp "$KEYCHAIN_NAME"

# --- Import the .p12 certificate into the keychain ---
if ! security import "$P12_FILE" -k "$KEYCHAIN_NAME" -P "$P12_PASSWORD" -T /usr/bin/codesign; then
    echo "Error: Failed to import .p12 file. Check the password and file integrity."
    exit 1
fi

# --- Set keychain as default ---
security default-keychain -s "$KEYCHAIN_NAME"

# --- Logos Processing ---
if ! Logos Tweak.xm > "$LOGOS_OUTPUT"; then
    echo "Error: Logos processing failed."
    exit 1
fi

# --- Compilation ---
if ! swiftc -target arm64-apple-ios14.0 \
    -emit-library \
    CPUInfoProvider.swift \
    MemoryInfoProvider.swift \
    InfoWindow.swift \
    FloatingButton.swift \
    SystemInfo.swift \
    "$LOGOS_OUTPUT" \
    -o "$DYLIB_NAME" \
    -framework UIKit \
    -framework Foundation \
    -framework CoreGraphics; then
    echo "Error: Compilation failed."
    exit 1
fi

# --- Tweak Packaging ---

# Create the tweak directory structure
mkdir -p "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries"
mkdir -p "$TWEAK_DIR/DEBIAN"

# Copy the dynamic library if it exists
if [ -f "$DYLIB_NAME" ]; then
    cp "$DYLIB_NAME" "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries/$DYLIB_NAME"
else
    echo "Error: $DYLIB_NAME not found."
    exit 1
fi

# Ensure the control file ends with a newline
if ! tail -c1 control | read -r _ || [ -z "$REPLY" ]; then
    echo "" >> control
fi

# Copy the control file
cp control "$TWEAK_DIR/DEBIAN/control"

# Create a dummy Tweak.x (or copy the original)
cp Tweak.x "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries/Tweak.x"

# Create the .deb package
if ! dpkg-deb -b "$TWEAK_DIR" "$DEB_PACKAGE"; then
    echo "Error: Failed to create .deb package."
    exit 1
fi

# --- Code Signing ---

# Unlock Keychain (if needed) and Sign the dylib with ldid
security unlock-keychain -p temp "$KEYCHAIN_NAME"

# Sign the dylib with ldid
if ! ldid -S"$ENTITLEMENTS" "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries/$DYLIB_NAME"; then
    echo "Error: Code signing failed."
    exit 1
fi

# --- Remove the temporary keychain ---
security delete-keychain "$KEYCHAIN_NAME"

echo "Build complete. Output: $DEB_PACKAGE"