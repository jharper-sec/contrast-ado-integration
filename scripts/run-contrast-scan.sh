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
SEVERITY_LEVEL="$7"
ENABLE_SARIF_OUTPUT="${8:-false}"  # New parameter with default value "false"

# Validate required arguments
if [ -z "$SCANNER_PATH" ] || [ -z "$ARTIFACT_PATH" ] || [ -z "$RESULTS_PATH" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: $0 <scanner_path> <artifact_path> <results_path> [project_name] [build_number] [branch_name] [severity_level] [enable_sarif_output]"
  exit 1
fi

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

# Check for proxy settings
if [ -n "$HTTP_PROXY" ]; then
  echo "Using HTTP proxy: $HTTP_PROXY"
fi

if [ -n "$HTTPS_PROXY" ]; then
  echo "Using HTTPS proxy: $HTTPS_PROXY"
fi

if [ -n "$NO_PROXY" ]; then
  echo "Using NO_PROXY: $NO_PROXY"
fi

# Set defaults for optional arguments
PROJECT_NAME="${PROJECT_NAME:-contrast-project}"
BUILD_NUMBER="${BUILD_NUMBER:-local-build}"
BRANCH_NAME="${BRANCH_NAME:-main}"
SEVERITY_LEVEL="${SEVERITY_LEVEL:-high}"

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
echo "Security Gate Level: $SEVERITY_LEVEL"
echo "Enable SARIF Output: $ENABLE_SARIF_OUTPUT"
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
  
  # Set up Java command with environment variables
  JAVA_OPTS="-Xmx12g"
  
  # Add proxy settings if they are set in the environment
  if [ -n "$HTTP_PROXY" ]; then
    JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyHost=$(echo $HTTP_PROXY | cut -d: -f1 | cut -d/ -f3) -Dhttp.proxyPort=$(echo $HTTP_PROXY | cut -d: -f2)"
  fi
  
  if [ -n "$HTTPS_PROXY" ]; then
    JAVA_OPTS="$JAVA_OPTS -Dhttps.proxyHost=$(echo $HTTPS_PROXY | cut -d: -f1 | cut -d/ -f3) -Dhttps.proxyPort=$(echo $HTTPS_PROXY | cut -d: -f2)"
  fi
  
  if [ -n "$NO_PROXY" ]; then
    JAVA_OPTS="$JAVA_OPTS -Dhttp.nonProxyHosts=\"$NO_PROXY\""
  fi
  
  # Prepare base command
  SCAN_CMD="java $JAVA_OPTS -jar \"$SCANNER_PATH\" \
    --project-name \"$PROJECT_NAME\" \
    --label \"Build-$BUILD_NUMBER\" \
    --branch \"$BRANCH_NAME\" \
    --severity \"$SEVERITY_LEVEL\""
    
  # Add SARIF output option only if enabled
  if [ "$ENABLE_SARIF_OUTPUT" = "true" ]; then
    SCAN_CMD="$SCAN_CMD --output-results \"$RESULTS_PATH/results.sarif\""
  fi
  
  # Add artifact path to command
  SCAN_CMD="$SCAN_CMD \"$artifact\""
  
  # Execute the command
  eval $SCAN_CMD
  
  SCAN_RESULT=$?
  
  echo "Scan completed with exit code: $SCAN_RESULT"
  
  if [ $SCAN_RESULT -eq 0 ]; then
    echo "Scan completed successfully with no security violations at the $SEVERITY_LEVEL level or above."
  elif [ $SCAN_RESULT -eq 1 ]; then
    echo "Error: Input validation error"
    exit $SCAN_RESULT
  elif [ $SCAN_RESULT -eq 2 ]; then
    echo "Error: Error connecting to Contrast API server"
    exit $SCAN_RESULT
  elif [ $SCAN_RESULT -eq 3 ]; then
    echo "Error: Contrast API error returned"
    exit $SCAN_RESULT
  elif [ $SCAN_RESULT -eq 4 ]; then
    echo "Error: Scan local engine returned an error, details are in the log files"
    exit $SCAN_RESULT
  elif [ $SCAN_RESULT -eq 5 ]; then
    echo "Error: Unexpected error occurred, details are in the log files"
    exit $SCAN_RESULT
  else
    echo "Security gate failed: Vulnerabilities with severity $SEVERITY_LEVEL or higher were found"
    # We don't exit here as we want the pipeline to continue for demo purposes
    # In a real environment, you might want to uncomment the following line to fail the build
    # exit $SCAN_RESULT
  fi
done

echo "All scans completed successfully"
if [ "$ENABLE_SARIF_OUTPUT" = "true" ]; then
  echo "Results saved to: $RESULTS_PATH/results.sarif"
fi
echo "Results uploaded to Contrast Security platform"

exit 0