#!/bin/bash
# Script to run the Contrast Security Local Scan Engine
# This script executes the scan and handles result processing

# Exit on any error
set -e

# Get arguments
SCANNER_PATH="$1"
ARTIFACT_PATH="$2"
RESULTS_PATH="$3"
PROJECT_NAME="$4"
BUILD_NUMBER="$5"
BRANCH_NAME="$6"

# Validate required arguments
if [ -z "$SCANNER_PATH" ] || [ -z "$ARTIFACT_PATH" ] || [ -z "$RESULTS_PATH" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: $0 <scanner_path> <artifact_path> <results_path> [project_name] [build_number] [branch_name]"
  exit 1
fi

# Set defaults for optional arguments
PROJECT_NAME="${PROJECT_NAME:-contrast-project}"
BUILD_NUMBER="${BUILD_NUMBER:-local-build}"
BRANCH_NAME="${BRANCH_NAME:-main}"

# Create output directory if it doesn't exist
mkdir -p "$RESULTS_PATH"

# Display configuration (hiding sensitive information)
echo "=== Contrast Security Local Scan Configuration ==="
echo "Project Name: $PROJECT_NAME"
echo "Branch: $BRANCH_NAME"
echo "Build: $BUILD_NUMBER"
echo "Scanner Path: $SCANNER_PATH"
echo "Artifact Path: $ARTIFACT_PATH"
echo "Results Path: $RESULTS_PATH"
echo "Contrast URL: $CONTRAST__API__URL"
echo "Contrast Username: ${CONTRAST__API__USER_NAME:0:3}...${CONTRAST__API__USER_NAME: -4}"
echo "=================================================="

# Check if scanner file exists
if [ ! -f "$SCANNER_PATH" ]; then
  echo "Error: Scanner file not found at $SCANNER_PATH"
  exit 1
fi

# Find all artifacts to scan
echo "Looking for artifacts to scan in $ARTIFACT_PATH"
ARTIFACTS=$(find "$ARTIFACT_PATH" -name "*.jar" -type f 2>/dev/null || true)

if [ -z "$ARTIFACTS" ]; then
  echo "Error: No artifacts (*.jar) found to scan in $ARTIFACT_PATH"
  exit 1
fi

echo "Found $(echo "$ARTIFACTS" | wc -l) artifact(s) to scan"

# Run the scan for each artifact
for artifact in $ARTIFACTS; do
  echo "Scanning: $artifact"
  
  # Execute the scanner with appropriate memory allocation
  # Adjust memory settings based on your environment
  java -Xmx12g -jar "$SCANNER_PATH" \
    --project-name "$PROJECT_NAME" \
    --label "Build-$BUILD_NUMBER" \
    --branch "$BRANCH_NAME" \
    --output "$RESULTS_PATH/results.sarif" \
    "$artifact"
  
  SCAN_RESULT=$?
  
  echo "Scan completed with exit code: $SCAN_RESULT"
  
  if [ $SCAN_RESULT -ne 0 ]; then
    echo "Error: Scan failed with exit code $SCAN_RESULT"
    exit $SCAN_RESULT
  fi
done

echo "All scans completed successfully"
echo "Results saved to: $RESULTS_PATH/results.sarif"
echo "Results uploaded to Contrast Security platform"

exit 0
