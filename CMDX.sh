#!/bin/bash

# --- Variables ---
PROJECT_NAME="SystemInfo"
DYLIB_NAME="CMDX.dylib"
DEB_PACKAGE="$PROJECT_NAME.deb"
TWEAK_DIR="tmp_tweak"
LOGOS_OUTPUT="Tweak.x.m"
MOBILEPROVISION="BDG.mobileprovision"  # Explicitly set to BDG.mobileprovision
ENTITLEMENTS="entitlements.plist"      # Temporary file for extracted entitlements

# --- Functions ---
function check_command {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "Command $1 not found. Please install it."; exit 1; }
}

function install_plistbuddy {
    if ! [ -x "/usr/libexec/PlistBuddy" ]; then
        echo "PlistBuddy not found at /usr/libexec/PlistBuddy. Attempting to install via Homebrew..."
        if ! command -v brew &> /dev/null; then
            echo "Homebrew not found. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        # Note: Homebrew doesn't directly provide PlistBuddy as a package. 
        # We'll assume a hypothetical package or manual installation step.
        echo "PlistBuddy is typically bundled with macOS. Attempting a workaround installation..."
        # For demonstration, we'll assume a manual download or check for Xcode tools
        if ! xcode-select -p &> /dev/null; then
            echo "Xcode command line tools not found. Installing..."
            xcode-select --install
            echo "Please follow the prompts to install Xcode command line tools, then rerun the script."
            exit 1
        fi
        # Verify again after attempting installation
        if ! [ -x "/usr/libexec/PlistBuddy" ]; then
            echo "Error: PlistBuddy still not found after attempted installation. Please install it manually."
            exit 1
        fi
    fi
}

# --- Check for necessary commands ---
check_command security
check_command swiftc
check_command dpkg-deb
check_command ldid

# --- Ensure PlistBuddy is installed ---
install_plistbuddy

# --- Ensure Logos is installed ---
if ! command -v logos &> /dev/null
then
    echo "Logos not found. Installing Logos using Homebrew..."
    brew install logos
fi

# --- Extract Entitlements from BDG.mobileprovision ---
if [ ! -f "$MOBILEPROVISION" ]; then
    echo "Error: $MOBILEPROVISION not found. Please ensure BDG.mobileprovision exists in the current directory."
    exit 1
fi

echo "Extracting entitlements from $MOBILEPROVISION..."
# Decode the .mobileprovision and extract the Entitlements dictionary
security cms -D -i "$MOBILEPROVISION" > decoded_provision.plist
/usr/libexec/PlistBuddy -x -c "Print Entitlements" decoded_provision.plist > "$ENTITLEMENTS" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract entitlements from $MOBILEPROVISION."
    rm decoded_provision.plist  # Clean up even on failure
    exit 1
fi
rm decoded_provision.plist  # Clean up temporary file

# --- Logos Processing ---
if ! logos Tweak.xm > "$LOGOS_OUTPUT"; then
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

# Sign the dylib with ldid using the extracted entitlements from BDG.mobileprovision
if ! ldid -S"$ENTITLEMENTS" "$TWEAK_DIR/Library/MobileSubstrate/DynamicLibraries/$DYLIB_NAME"; then
    echo "Error: Code signing failed."
    exit 1
fi

# --- Cleanup ---
rm -f "$ENTITLEMENTS"  # Remove temporary entitlements file

echo "Build complete. Output: $DEB_PACKAGE"