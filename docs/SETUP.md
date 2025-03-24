# Setup Guide - Contrast Security Local Scan Engine with Azure DevOps

This guide provides step-by-step instructions for setting up the Contrast Security Local Scan Engine integration with Azure DevOps.

## Prerequisites

Before you begin, ensure you have the following:

1. **Contrast Security Account**:
   - Valid Contrast Security account
   - Access to the Contrast Security platform
   - API credentials (API Key, Service Key, Organization ID)
   - Access to download the Local Scan Engine JAR file

2. **Azure DevOps Environment**:
   - Azure DevOps project with pipeline creation permissions
   - Access to create variable groups and pipeline variables
   - Ability to run pipelines on a suitable agent

3. **Build Agent Requirements**:
   - Java 17 (Oracle Java 17 recommended)
   - Minimum 12GB RAM for running the scanner
   - Internet connectivity to the Contrast Security platform

## Step 1: Obtain the Contrast Security Local Scan Engine

Contact Contrast Security support to obtain the Local Scan Engine JAR file (`sast-local-scan-runner-x.y.z.jar`). Alternatively, modify the `scripts/download-scanner.sh` script to download it from your authorized location.

## Step 2: Set Up Azure DevOps Pipeline Variables

1. Navigate to your Azure DevOps project
2. Go to Pipelines > Library
3. Create a variable group named "Contrast Security Configuration"
4. Add the following variables (mark the sensitive ones as secret):

   | Variable | Description | Secret |
   |----------|-------------|--------|
   | `CONTRAST__API__URL` | Contrast platform URL | No |
   | `CONTRAST__API__USER_NAME` | Your Contrast username | Yes |
   | `CONTRAST__API__API_KEY` | Your API Key | Yes |
   | `CONTRAST__API__SERVICE_KEY` | Your Service Key | Yes |
   | `CONTRAST__API__ORGANIZATION` | Your Organization ID | Yes |
   | `maxHighSeverity` | Maximum allowed high severity findings | No |
   | `maxMediumSeverity` | Maximum allowed medium severity findings | No |

## Step 3: Configure Pipeline File Permissions

1. Ensure that all scripts in the `scripts` directory are executable:
   ```bash
   chmod +x scripts/*.sh
   ```

2. If using a Git repository, add these files to Git:
   ```bash
   git add scripts/*.sh
   git commit -m "Make scripts executable"
   git push
   ```

## Step 4: Update the Download Scanner Script

Modify the `scripts/download-scanner.sh` script to use your actual method for obtaining the scanner:

1. Open `scripts/download-scanner.sh`
2. Replace the placeholder code with your actual download method
3. Save the changes

## Step 5: Set Up the Azure DevOps Pipeline

1. In Azure DevOps, go to Pipelines > Pipelines
2. Click "New Pipeline"
3. Select your repository
4. Choose "Existing Azure Pipelines YAML file"
5. Select the path to the file: `.azure/pipelines/contrast-scan-pipeline.yml`
6. Click "Continue"
7. Review the pipeline configuration
8. Click "Run" to save and run the pipeline

## Step 6: Configure Security Policy

1. Review the default security gate policy in `config/security-gate-policy.json`
2. Adjust the thresholds as needed based on your organization's security requirements
3. Update the pipeline variables with the corresponding values

## Step 7: Verify the Integration

1. Run the pipeline
2. Check that each stage (Build, SecurityScan, Deploy) executes correctly
3. Verify that scan results are published as pipeline artifacts
4. Check that you can view the scan results in the Contrast Security platform

## Troubleshooting

If you encounter issues, refer to the [Troubleshooting Guide](TROUBLESHOOTING.md) for solutions to common problems.

## Next Steps

- Customize the pipeline templates for your specific build and deployment requirements
- Adjust the security gate thresholds based on your risk tolerance
- Configure notifications for security scan failures
- Integrate with additional monitoring or reporting tools
