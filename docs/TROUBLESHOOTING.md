# Troubleshooting Guide - Contrast Security Local Scan Engine with Azure DevOps

This guide provides solutions for common issues you might encounter when using the Contrast Security Local Scan Engine with Azure DevOps.

## Common Issues and Solutions

### Scanner Download Issues

#### Issue: Cannot download the scanner

**Symptoms:**
- `download-scanner.sh` script fails
- Error message about inability to download the scanner

**Solutions:**
- Verify network connectivity from the build agent to the download location
- Check authentication credentials for the download
- Ensure the download URL is correct and accessible
- Consider manually uploading the scanner to a secure location accessible by the build agent

### Scanner Execution Issues

#### Issue: Out of memory error

**Symptoms:**
- Java heap space error
- Scanner terminates unexpectedly

**Solutions:**
- Increase the Java memory allocation in the `run-contrast-scan.sh` script
- Use a build agent with more memory (12GB minimum recommended)
- Adjust the `-Xmx` parameter value (e.g., `-Xmx12g`)

#### Issue: Java version incompatibility

**Symptoms:**
- Error about unsupported class version
- Scanner fails to start

**Solutions:**
- Ensure Java 17 is installed on the build agent
- Verify the Java version being used by the scanner with `java -version`
- Check that the correct Java version is selected in the pipeline tasks

### API Connection Issues

#### Issue: Authentication failure

**Symptoms:**
- Error about invalid API credentials
- Scanner cannot connect to Contrast platform

**Solutions:**
- Verify the API credentials in the pipeline variables
- Check that the correct organization ID is being used
- Ensure the API keys have not expired
- Verify the user has appropriate permissions in Contrast Security

#### Issue: Network connectivity problems

**Symptoms:**
- Timeout errors
- Connection refused errors

**Solutions:**
- Check network connectivity from the build agent to the Contrast platform
- Configure proxy settings if using a corporate proxy
- Verify firewall rules allow outbound connections

### Results Processing Issues

#### Issue: SARIF file not generated

**Symptoms:**
- Missing results file
- Cannot find the SARIF output

**Solutions:**
- Check the output path in the scanner command
- Verify that the scanner ran successfully
- Ensure the output directory has write permissions

#### Issue: Security gate fails unexpectedly

**Symptoms:**
- Build fails at the security gate step
- Unexpected vulnerability thresholds being applied

**Solutions:**
- Check the security threshold values in the pipeline variables
- Review the SARIF results to understand the actual vulnerabilities found
- Adjust thresholds if needed for your specific project

## Advanced Troubleshooting

### Pipeline Debugging

To enable more detailed debugging:

1. Edit the pipeline
2. Add the following at the top of your YAML file:
   ```yaml
   variables:
     system.debug: true
   ```
3. Run the pipeline again to see more detailed logs

### Scanner Debugging

To get more detailed logs from the scanner:

1. Modify the `run-contrast-scan.sh` script
2. Add debugging flags to the Java command:
   ```bash
   java -Xmx12g -Dcontrast.log.level=DEBUG -jar "$SCANNER_PATH" ...
   ```

### Manual Scan Verification

If you suspect issues with the scanner itself:

1. Download the scanner JAR to a local machine
2. Run it manually against your artifacts
3. Verify that the scan completes and produces valid results
4. Compare with the pipeline execution

## Getting Help

If you continue to experience issues:

1. Contact Contrast Security support with:
   - Your scanner version
   - The error logs
   - Your pipeline configuration
   - The SARIF output (if available)

2. Open an issue in your project repository with detailed information about the problem

3. Check the official Contrast Security documentation for updates on known issues
