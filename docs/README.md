# RF IQ Analyst Documentation

This documentation provides comprehensive guidance for building, deploying, and using the RF IQ Analyst application in Docker containers.

## Documentation Structure

### Quick Start
- **[DOCKER-README.md](../DOCKER-README.md)** - Docker setup and basic usage instructions

### User Documentation  
- **[USER-GUIDE.md](USER-GUIDE.md)** - Complete application user guide with interface overview, signal analysis workflows, and ML classification features

### Technical Documentation
- **[TECHNICAL-REFERENCE.md](TECHNICAL-REFERENCE.md)** - Architecture details, API reference, build system, and advanced configuration for developers

## Getting Started

### 1. System Requirements
- **Windows 10/11** with WSL2 and Docker Desktop
- **8GB RAM minimum** (16GB recommended for ML training)
- **X11 Server** (VcXsrv) for GUI applications
- **Git** for source code management

### 2. Quick Setup
```powershell
# 1. Clone the repository
git clone <repository-url>
cd rf_iq_analyst.lmd

# 2. Build the Docker image
.\build-docker.bat

# 3. Start VcXsrv X Server
.\validate-setup.bat

# 4. Run the application
.\run-gui-windows.bat
```

### 3. Application Features
- **Signal Analysis**: Real-time spectrum analysis and signal detection
- **ML Classification**: TensorFlow-based automatic signal classification
- **Data Export**: Multiple format support for analysis results
- **VRT Support**: VITA 49 packet processing and GPS integration

## Navigation Guide

| If you want to... | Read this document |
|-------------------|-------------------|
| **Set up Docker and run the application** | [DOCKER-README.md](../DOCKER-README.md) |
| **Learn how to use the application interface** | [USER-GUIDE.md](USER-GUIDE.md) |
| **Understand the system architecture** | [TECHNICAL-REFERENCE.md](TECHNICAL-REFERENCE.md) |
| **Develop or modify the application** | [TECHNICAL-REFERENCE.md](TECHNICAL-REFERENCE.md) |
| **Troubleshoot issues** | [DOCKER-README.md](../DOCKER-README.md#troubleshooting) |
| **Train ML models** | [USER-GUIDE.md](USER-GUIDE.md#machine-learning-classification) |

## Common Use Cases

### Signal Analysis Workflow
1. **Load IQ Data**: Import signal files (various formats supported)
2. **Configure Analysis**: Set FFT parameters, filtering, and display options
3. **Analyze Signals**: Use spectrum analyzer and signal detection tools
4. **Export Results**: Save analysis results and screenshots

### ML Classification Workflow
1. **Prepare Training Data**: Organize signal samples into class directories
2. **Train Models**: Use integrated TensorFlow training (IQ or FFT-based)
3. **Classify Signals**: Apply trained models to unknown signals
4. **Evaluate Performance**: Review classification metrics and results

### Development Workflow
1. **Build Environment**: Use Docker for consistent development environment
2. **Code Changes**: Modify C++ or Python components as needed
3. **Testing**: Validate changes with sample data and unit tests
4. **Deployment**: Package updates into new Docker images

## Support and Troubleshooting

### Common Issues
- **X11 Display Problems**: See VcXsrv setup in [DOCKER-README.md](../DOCKER-README.md)
- **Memory Limitations**: Adjust Docker memory allocation for large datasets
- **Python Dependencies**: Ensure TensorFlow and ML libraries are properly installed
- **Build Failures**: Check Qt5 and signal processing library dependencies

### Getting Help
1. **Check Documentation**: Review appropriate guide for your use case
2. **Verify Setup**: Run validation scripts to check system configuration
3. **Review Logs**: Check application and Docker container logs for errors
4. **Performance Issues**: See optimization guidelines in technical reference

## Version Information

- **Application**: RF IQ Analyst (Qt5-based signal processing application)
- **Docker Base**: Ubuntu 22.04 LTS
- **ML Framework**: TensorFlow 2.12.0 with Python 3.10
- **Signal Processing**: FFTW3, liquid-dsp, OpenCV, Boost libraries
- **Documentation Version**: 1.0 (Created with comprehensive Docker integration)

---

**Note**: This documentation is designed to be self-contained and comprehensive. Each document serves a specific purpose and audience, with clear cross-references to related information.
