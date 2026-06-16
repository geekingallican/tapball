#!/bin/bash
# Flutter + Android SDK + Emulator Setup Script
# Supports Linux and macOS
# Run: bash setup-android-emulator.sh

set -e

echo "========================================="
echo "Android SDK & Emulator Setup"
echo "========================================="

# Detect OS
OS=$(uname -s)
ARCH=$(uname -m)

if [[ "$OS" == "Linux" ]]; then
    echo "✓ Detected: Linux"
    SDK_OS="linux"
    if [[ "$ARCH" == "x86_64" ]]; then
        SDK_ARCH="x86_64"
    else
        echo "✗ Unsupported architecture: $ARCH"
        exit 1
    fi
elif [[ "$OS" == "Darwin" ]]; then
    echo "✓ Detected: macOS"
    SDK_OS="mac"
    if [[ "$ARCH" == "arm64" ]]; then
        SDK_ARCH="arm64"
    elif [[ "$ARCH" == "x86_64" ]]; then
        SDK_ARCH="x86_64"
    else
        echo "✗ Unsupported architecture: $ARCH"
        exit 1
    fi
else
    echo "✗ Unsupported OS: $OS"
    exit 1
fi

# Setup paths
ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
WORK_DIR=$(mktemp -d)

echo "Using ANDROID_HOME: $ANDROID_HOME"
echo "Work directory: $WORK_DIR"

# Check prerequisites
echo ""
echo "Checking prerequisites..."

if ! command -v java &> /dev/null; then
    echo "✗ Java not found. Please install Java 11 or later."
    exit 1
fi
echo "✓ Java found: $(java -version 2>&1 | head -n 1)"

if ! command -v curl &> /dev/null; then
    echo "✗ curl not found"
    exit 1
fi
echo "✓ curl found"

if ! command -v unzip &> /dev/null; then
    echo "✗ unzip not found"
    exit 1
fi
echo "✓ unzip found"

# Download and install command-line tools
echo ""
echo "Downloading Android command-line tools..."
mkdir -p "$ANDROID_HOME/cmdline-tools/latest"

CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-${SDK_OS}-latest.zip"
CMDLINE_ZIP="$WORK_DIR/cmdline-tools.zip"

if ! curl -fsSL -o "$CMDLINE_ZIP" "$CMDLINE_TOOLS_URL"; then
    echo "✗ Failed to download command-line tools from $CMDLINE_TOOLS_URL"
    echo "Try manually downloading from: https://developer.android.com/studio#command-line-tools-only"
    exit 1
fi

echo "✓ Downloaded command-line tools ($(du -h "$CMDLINE_ZIP" | cut -f1))"

echo "Extracting and installing..."
mkdir -p "$WORK_DIR/cmdline-extract"
unzip -q "$CMDLINE_ZIP" -d "$WORK_DIR/cmdline-extract"

# Move to proper location
if [ -d "$WORK_DIR/cmdline-extract/cmdline-tools" ]; then
    mv "$WORK_DIR/cmdline-extract/cmdline-tools"/* "$ANDROID_HOME/cmdline-tools/latest/" 2>/dev/null || true
else
    mv "$WORK_DIR/cmdline-extract"/* "$ANDROID_HOME/cmdline-tools/latest/" 2>/dev/null || true
fi

# Verify sdkmanager
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "✗ sdkmanager not found after installation"
    exit 1
fi
echo "✓ sdkmanager installed"

# Export environment variables for this session
export ANDROID_HOME
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Accept licenses
echo ""
echo "Accepting Android licenses..."
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses >/dev/null 2>&1 || true

# Install SDK components
echo ""
echo "Installing SDK components (this may take a few minutes)..."
COMPONENTS=(
    "platform-tools"
    "platforms;android-33"
    "platforms;android-34"
    "build-tools;33.0.0"
    "emulator"
    "system-images;android-33;google_apis;x86_64"
)

for component in "${COMPONENTS[@]}"; do
    echo "  Installing: $component"
    yes | sdkmanager --sdk_root="$ANDROID_HOME" --install "$component" >/dev/null 2>&1 || true
done

echo "✓ SDK components installed"

# Create AVD
echo ""
echo "Creating Android Virtual Device (AVD: testAVD)..."

# Check if avdmanager exists
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" ]; then
    echo "✗ avdmanager not found"
    exit 1
fi

# Create AVD (suppress prompts)
echo no | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" \
    create avd \
    -n testAVD \
    -k "system-images;android-33;google_apis;x86_64" \
    --force 2>/dev/null || true

echo "✓ AVD created"

# List available AVDs
echo ""
echo "Available AVDs:"
"$ANDROID_HOME/emulator/emulator" -list-avds

# Start emulator
echo ""
echo "Starting emulator (testAVD)..."
echo "Note: Emulator window will appear. Keep it running to test with Flutter."
echo ""

# Launch emulator in background
"$ANDROID_HOME/emulator/emulator" \
    -avd testAVD \
    -no-snapshot \
    -wipe-data \
    -gpu swiftshader \
    &

EMULATOR_PID=$!
echo "✓ Emulator started (PID: $EMULATOR_PID)"
echo "  Waiting 15 seconds for boot..."

sleep 15

# Verify device
echo ""
echo "Checking device connection..."
if command -v adb &> /dev/null; then
    adb devices -l || true
fi

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Your emulator should now be running."
echo ""
echo "To test with Flutter:"
echo "  1. Open a new terminal"
echo "  2. Navigate to your Flutter project"
echo "  3. Run: flutter devices"
echo "  4. Run: flutter run"
echo ""
echo "Environment variables for future sessions:"
echo "  export ANDROID_HOME=\"$ANDROID_HOME\""
echo "  export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH\""
echo ""
echo "Add to ~/.bashrc or ~/.zshrc to make permanent."
