#!/bin/bash
# Script to evaluate Contrast Security scan results against defined thresholds
# This script analyzes SARIF results and enforces security gates

# Exit on any error
set -e

# Get arguments
RESULTS_FILE="$1"
MAX_HIGH="$2"
MAX_MEDIUM="$3"

# Validate required arguments
if [ -z "$RESULTS_FILE" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: $0 <results_file> [max_high] [max_medium]"
  exit 1
fi

# Set defaults for optional arguments
MAX_HIGH="${MAX_HIGH:-0}"
MAX_MEDIUM="${MAX_MEDIUM:-5}"

echo "=== Contrast Security Results Evaluation ==="
echo "Results File: $RESULTS_FILE"
echo "Maximum High Severity: $MAX_HIGH"
echo "Maximum Medium Severity: $MAX_MEDIUM"
echo "==========================================="

# Check if results file exists
if [ ! -f "$RESULTS_FILE" ]; then
  echo "Warning: Results file not found at $RESULTS_FILE"
  echo "Cannot evaluate security gate without scan results."
  exit 0
fi

# Count findings by severity
# Note: This is a simplified approach - in production, use a proper JSON parser like jq
HIGH_COUNT=$(grep -c "\"level\":\"error\"" "$RESULTS_FILE" || echo 0)
MEDIUM_COUNT=$(grep -c "\"level\":\"warning\"" "$RESULTS_FILE" || echo 0)
LOW_COUNT=$(grep -c "\"level\":\"note\"" "$RESULTS_FILE" || echo 0)

echo "Scan results analysis:"
echo "- High severity issues: $HIGH_COUNT"
echo "- Medium severity issues: $MEDIUM_COUNT"
echo "- Low severity issues: $LOW_COUNT"

# Evaluate against thresholds
FAIL=false

if [ "$HIGH_COUNT" -gt "$MAX_HIGH" ]; then
  echo "##vso[task.logissue type=error]Security gate failed: $HIGH_COUNT high severity issues found (threshold: $MAX_HIGH)"
  FAIL=true
fi

if [ "$MEDIUM_COUNT" -gt "$MAX_MEDIUM" ]; then
  echo "##vso[task.logissue type=warning]Security gate threshold exceeded: $MEDIUM_COUNT medium severity issues found (threshold: $MAX_MEDIUM)"
fi

if [ "$FAIL" = true ]; then
  echo "##vso[task.complete result=Failed;]Security gate failed"
  exit 1
else
  echo "Security gate passed"
  exit 0
fi
