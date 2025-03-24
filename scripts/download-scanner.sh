#!/bin/bash
# Script to download the Contrast Security Local Scan Engine
# This script downloads the latest version of the Scan local engine application

# Exit on any error
set -e

# Get the scanner path from arguments
FINAL_JAR_PATH="$1"
if [ -z "$FINAL_JAR_PATH" ]; then
  echo "Error: Target JAR path not specified"
  echo "Usage: $0 <target_jar_path>"
  exit 1
fi

# Create directory for scanner if it doesn't exist
mkdir -p "$(dirname "$FINAL_JAR_PATH")"

# Set the release version (default to latest)
RELEASE="latest"
if [ -n "$2" ]; then
  RELEASE="$2"
fi

# Set up temporary directory for downloaded files
TEMP_DIR="$(dirname "$FINAL_JAR_PATH")/temp"
mkdir -p "$TEMP_DIR"
OUTPUT_FILE="$TEMP_DIR/sast-local-scanner-$RELEASE.zip"

# Verify environment variables
if [ -z "$CONTRAST__API__ORGANIZATION" ] || \
   [ -z "$CONTRAST__API__URL" ] || \
   [ -z "$CONTRAST__API__USER_NAME" ] || \
   [ -z "$CONTRAST__API__API_KEY" ] || \
   [ -z "$CONTRAST__API__SERVICE_KEY" ]; then
  echo "Error: Required environment variables are not set."
  echo "Please ensure the following variables are set:"
  echo "  - CONTRAST__API__ORGANIZATION"
  echo "  - CONTRAST__API__URL"
  echo "  - CONTRAST__API__USER_NAME"
  echo "  - CONTRAST__API__API_KEY"
  echo "  - CONTRAST__API__SERVICE_KEY"
  exit 1
fi

echo "=== Contrast Security Local Scan Engine Download ==="
echo "Release Version: $RELEASE"
echo "Organization ID: ${CONTRAST__API__ORGANIZATION:0:5}...${CONTRAST__API__ORGANIZATION: -5}"
echo "Contrast URL: $CONTRAST__API__URL"
echo "Username: ${CONTRAST__API__USER_NAME:0:3}...${CONTRAST__API__USER_NAME: -4}"
echo "Downloaded ZIP will be saved to: $OUTPUT_FILE"
echo "Final JAR path: $FINAL_JAR_PATH"
echo "================================================="

# Generate the authentication token
AUTH_TOKEN=$(echo -n $CONTRAST__API__USER_NAME:$CONTRAST__API__SERVICE_KEY | base64)

# Download the scanner
echo "Downloading Contrast Security Local Scan Engine..."

# Set up curl command with basic options
CURL_OPTS=(
  "-H" "api-key: $CONTRAST__API__API_KEY"
  "-H" "authorization: $AUTH_TOKEN"
  "-L"
  "-o" "$OUTPUT_FILE"
)

# Add proxy settings if they are set in the environment
if [ -n "$HTTP_PROXY" ]; then
  echo "Using HTTP proxy: $HTTP_PROXY"
  CURL_OPTS+=("--proxy" "$HTTP_PROXY")
fi

if [ -n "$HTTPS_PROXY" ]; then
  echo "Using HTTPS proxy: $HTTPS_PROXY"
  CURL_OPTS+=("--proxy" "$HTTPS_PROXY")
fi

if [ -n "$NO_PROXY" ]; then
  echo "Using NO_PROXY: $NO_PROXY"
  CURL_OPTS+=("--noproxy" "$NO_PROXY")
fi

# Execute curl command with all options
curl "${CURL_OPTS[@]}" "$CONTRAST__API__URL/organizations/$CONTRAST__API__ORGANIZATION/release-artifacts/local-scanner/$RELEASE?download=true"

DOWNLOAD_STATUS=$?
if [ $DOWNLOAD_STATUS -ne 0 ]; then
  echo "Error: Failed to download scanner (curl exit code: $DOWNLOAD_STATUS)"
  exit $DOWNLOAD_STATUS
fi

# Verify download
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "Error: Downloaded file not found at $OUTPUT_FILE"
  exit 1
fi

echo "Download completed successfully. File size: $(du -h "$OUTPUT_FILE" | cut -f1)"

# Extract the downloaded ZIP file
echo "Extracting ZIP file..."
unzip -q -o "$OUTPUT_FILE" -d "$TEMP_DIR"

# Find the JAR file in the extracted contents
JAR_FILE=$(find "$TEMP_DIR" -name "*.jar" | grep -E 'sast-local-scan-runner.*\.jar$' | head -1)

if [ -z "$JAR_FILE" ]; then
  echo "Error: Could not find scanner JAR file in the extracted contents"
  exit 1
fi

# Copy the JAR file to the target location
echo "Moving JAR file to target location: $FINAL_JAR_PATH"
cp "$JAR_FILE" "$FINAL_JAR_PATH"

# Verify the final JAR file
if [ -f "$FINAL_JAR_PATH" ]; then
  echo "Scanner JAR file successfully installed at $FINAL_JAR_PATH"
  echo "Scanner version: $(java -jar "$FINAL_JAR_PATH" --version 2>/dev/null || echo "unknown")"
else
  echo "Error: Failed to install scanner JAR file"
  exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "Scanner installation completed successfully!"
exit 0
