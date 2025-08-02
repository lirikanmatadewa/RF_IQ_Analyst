# RF IQ Analyst - Docker Setup

This directory contains Docker configuration files to build and run the RF IQ Analyst application in a containerized environment.

## Quick Start (Windows Users)

### Prerequisites
1. **Docker Desktop** installed and running
2. **VcXsrv X Server** for GUI support (download from [here](https://sourceforge.net/projects/vcxsrv/))

### Step 1: Setup X Server
1. Install and run VcXsrv X Server
2. Use these settings:
   - Display number: `0`
   - Check "Disable access control"
   - Check "Native opengl"
   - Uncheck "Primary Selection"

### Step 2: Build and Run
Run the automated setup script:
```cmd
quick-start-windows.bat
```

Or manually:
```cmd
# Build the Docker image
build-docker.bat

# Run with GUI support
run-gui-windows.bat
```

### Step 3: Using the Application
Once the container starts:
1. The RF IQ Analyst GUI will appear on your Windows desktop
2. Use File menu to load IQ data files
3. Access ML classification features through the Classifier menu
4. Train models with your signal data
5. Classify unknown signals using trained models

## Prerequisites & System Requirements

### Hardware Requirements
- **CPU**: Multi-core processor (4+ cores recommended)
- **RAM**: 8GB minimum, 16GB recommended (for ML training)
- **Disk Space**: 5GB free space for Docker images and data
- **GPU**: Optional (CUDA support available but not required)

### Software Requirements
- **Windows 10/11** (64-bit)
- **Docker Desktop** 4.0+ with WSL2 backend
- **VcXsrv X Server** for GUI display
- **PowerShell** 5.0+ (for batch scripts)

## Files Overview

### Core Docker Files
- **`Dockerfile`** - Multi-stage build configuration for RF IQ Analyst
- **`docker-compose.yml`** - Simplified container management with GUI support
- **`.dockerignore`** - Excludes unnecessary files from Docker build context

### Windows Helper Scripts
- **`quick-start-windows.bat`** - Complete automated setup (build + run)
- **`build-docker.bat`** - Build the Docker image only
- **`run-gui-windows.bat`** - Run the application with X11 GUI forwarding
- **`test-x11-windows.bat`** - Test X11 connection to Windows
- **`validate-setup.bat`** - Check Docker and X server requirements

## Build Details

### Multi-Stage Build
The Dockerfile uses a multi-stage build approach:

1. **Builder Stage**: Ubuntu 22.04 with all development tools
   - Qt5 development packages
   - Signal processing libraries (FFTW3, liquid-dsp, Boost, OpenCV)
   - Python 3 with TensorFlow, NumPy, scikit-learn for ML classification
   - Builds: qvrt_util → libsdrkit → main application

2. **Runtime Stage**: Minimal Ubuntu 22.04 with only runtime dependencies
   - Only necessary Qt5 and library runtime packages
   - Python 3 runtime with ML packages for signal classification
   - Final application binary
   - Python classifier scripts and templates
   - Non-root user setup

### Dependencies Built
- **qvrt_util library** - Custom VRT utilities
- **libsdrkit library** - SDR toolkit components  
- **liquid-dsp** - Digital signal processing library (built from source)
- **Python ML environment** - TensorFlow, NumPy, scikit-learn for signal classification
- **Main application** - RF IQ Analyst GUI

## Machine Learning Classification

RF IQ Analyst includes TensorFlow-based signal classification capabilities:

### Python Scripts Included
- **`trainIQ.py`** - Train ML models on raw IQ data
- **`trainFFT.py`** - Train ML models on FFT data  
- **`predictIQ.py`** - Classify signals using raw IQ data models
- **`predictFFT.py`** - Classify signals using FFT data models
- **`datasetIQ.py`** / **`datasetFFT.py`** - Dataset loading utilities

### ML Dependencies
- **TensorFlow 2.12.0** - Deep learning framework
- **NumPy** - Numerical computing
- **scikit-learn** - Machine learning utilities

### How It Works
1. The C++ application calls Python scripts via QProcess
2. Scripts communicate back via UDP sockets on ports 5005-5006
3. Training data is loaded from numpy (.npy) files
4. Models are saved and loaded for signal classification

## Manual Docker Commands

### Build Image
```cmd
docker build -t rf-iq-analyst:latest .
```

### Run with GUI (Windows)
```cmd
docker run --rm -e DISPLAY=host.docker.internal:0.0 -e QT_X11_NO_MITSHM=1 rf-iq-analyst:latest
```

### Run with Docker Compose
```cmd
docker-compose up
```

## Troubleshooting

### X11 Connection Issues
- Ensure VcXsrv is running with "Disable access control" checked
- Try running `test-x11-windows.bat` to verify X11 setup
- Check Windows Firewall settings for VcXsrv

### Build Issues
- Ensure you have sufficient disk space (build requires ~2GB)
- Check Docker Desktop is running and has adequate memory allocated
- Try `docker system prune` to clean up space if needed

### Audio Warnings
ALSA audio warnings are normal and expected in containerized environments - they don't affect the application functionality.

### Python ML Issues
- **TensorFlow errors**: Ensure sufficient RAM (8GB+) for model training
- **Model loading fails**: Check if training data files (.npy) are accessible
- **UDP socket errors**: Ports 5005-5006 might be in use by other applications

### Performance Issues
- **Slow GUI response**: Increase Docker Desktop memory allocation (8GB+)
- **Build takes too long**: Use `docker system prune` to free up space
- **High CPU usage**: Limit Docker CPU cores in Desktop settings

## Technical Notes

### Image Size
- **Builder image**: ~2GB (includes all development tools)
- **Final runtime image**: ~1.2GB (includes Python ML dependencies)

### Build Time
- **First build**: ~2.5 minutes (depending on system)
- **Subsequent builds**: ~30 seconds (Docker layer caching)

### Security
- Application runs as non-root user `analyst`
- No privileged access required
- X11 forwarding uses standard protocols

## For Developers

### Modifying the Build
- Edit `Dockerfile` for build configuration changes
- The build script is dynamically generated during Docker build
- Libraries are built in dependency order: qvrt_util → libsdrkit → main app

### Adding Dependencies
- Add development packages to the builder stage
- Add corresponding runtime packages to the runtime stage  
- Update library paths in qmake configuration if needed

### Debugging Build Issues
- Use `docker build --no-cache` to force full rebuild
- Add `RUN ls -la` commands in Dockerfile to inspect build state
- Check `build.sh` script generation for syntax issues

## Data Management

### Persistent Data Storage
By default, the container doesn't persist data. To save your work:

```cmd
# Run with volume mount for data persistence
docker run --rm -e DISPLAY=host.docker.internal:0.0 -e QT_X11_NO_MITSHM=1 -v "%USERPROFILE%\rf-iq-data:/home/analyst/data" rf-iq-analyst:latest
```

### Supported File Formats
- **IQ Data**: Complex binary files, VITA 49 (VRT) format
- **Training Data**: NumPy (.npy) files for ML models
- **Models**: TensorFlow SavedModel format
- **Export**: CSV, JSON for analysis results

### Data Locations in Container
- **Application data**: `/home/analyst/data/`
- **ML models**: `/home/analyst/models/`
- **Python scripts**: `/usr/local/share/rf-iq-analyst/classifiers/`
- **Logs**: `/home/analyst/logs/`

## Additional Information

### Complete Documentation Structure
This project includes comprehensive documentation:

- **[docs/README.md](docs/README.md)** - Documentation navigation and overview
- **[docs/USER-GUIDE.md](docs/USER-GUIDE.md)** - Complete application user guide
- **[docs/TECHNICAL-REFERENCE.md](docs/TECHNICAL-REFERENCE.md)** - Architecture and API reference

### Quick Reference
- **Application Interface**: See [User Guide](docs/USER-GUIDE.md#interface-overview)
- **ML Classification**: See [ML Workflow](docs/USER-GUIDE.md#machine-learning-classification)
- **System Architecture**: See [Technical Reference](docs/TECHNICAL-REFERENCE.md#architecture-overview)
- **API Documentation**: See [API Reference](docs/TECHNICAL-REFERENCE.md#api-reference)

For detailed application features and usage beyond Docker setup, refer to the comprehensive documentation in the `docs/` directory.
