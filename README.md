# Contrast Security Local Scan Engine - Azure DevOps Integration

This project demonstrates how to integrate the Contrast Security Local Scan Engine with Azure DevOps pipelines using a script-based approach.

## Project Structure

```
contrast-ado-integration/
├── .azure/                  # Azure DevOps pipeline configurations
├── scripts/                 # Scripts for scanner operations
├── config/                  # Configuration files
├── docs/                    # Documentation
└── example-app/             # Example application
```

## Quick Start

See the [Setup Guide](docs/SETUP.md) for detailed instructions.

## Build Options

This project supports two build approaches:

### Option 1: Build using the root pom.xml (Multi-module)

The root level `pom.xml` file is configured as a multi-module Maven project that includes the example application. This can be used to build all modules at once:

```bash
mvn clean package
```

### Option 2: Build individual modules

To build only the example application directly:

```bash
cd example-app
mvn clean package
```

The Azure DevOps pipeline can be configured to use either approach:

- For the multi-module approach, use `mavenPomFile: 'pom.xml'` in the build task
- For building individual modules, use `mavenPomFile: 'example-app/pom.xml'`

## Pipeline Configuration

The pipeline configuration is located at:
```
.azure/pipelines/contrast-scan-pipeline.yml
```

See the [Documentation](docs/) directory for more details.
