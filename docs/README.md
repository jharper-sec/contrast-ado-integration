# Contrast Security Local Scan Engine - Azure DevOps Integration

This project demonstrates how to integrate the Contrast Security Local Scan Engine with Azure DevOps pipelines using a script-based approach. This integration enables automated security scanning of your application code and artifacts as part of your CI/CD process.

## Project Structure

```
contrast-ado-integration/
├── .azure/                          # Azure DevOps pipeline configurations
│   └── pipelines/
├── scripts/                         # Scripts for scanner operations
├── config/                          # Configuration files
├── docs/                            # Documentation
└── example-app/                     # Example application with security vulnerabilities
```

## Features

- **Build Stage**: Compiles the application code and generates artifacts
- **Security Scan Stage**: Uses Contrast Security Local Scan Engine to scan artifacts
- **Security Gate**: Enforces vulnerability thresholds before deployment
- **Deploy Stage**: Deploys the application if security scans pass

## Quick Start

1. Set up prerequisites (see [SETUP.md](SETUP.md))
2. Configure pipeline variables for Contrast Security authentication
3. Run the Azure DevOps pipeline using the main configuration file:
   ```
   .azure/pipelines/contrast-scan-pipeline.yml
   ```

## Documentation

- [Setup Guide](SETUP.md): Instructions for setting up the integration
- [Troubleshooting](TROUBLESHOOTING.md): Solutions for common issues

## Example Application

The project includes an example Spring Boot application with deliberately introduced security vulnerabilities to demonstrate the scanning capabilities:

- SQL Injection
- Cross-Site Scripting (XSS)
- Path Traversal
- Command Injection
- Insecure Cookie Configuration
- Hardcoded Credentials

**IMPORTANT**: The example application is for demonstration purposes only. Do not use it in production environments.

## Customization

The integration is designed to be customizable for your specific environment:

- Adjust security thresholds in the variables file
- Modify the scanner download process based on your procurement method
- Customize quality gates for different branches and environments

## Resources

- [Contrast Security Documentation](https://docs.contrastsecurity.com/)
- [Azure DevOps Pipelines Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
