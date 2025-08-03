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

### Step 4: Accessing Windows Files
The application can now access your Windows directories through mounted paths:
- **Windows C: Drive**: `/mnt/windows/C/` in the application
- **All Users**: `/mnt/windows/Users/` in the application  
- **Your Documents**: `/mnt/windows/Documents/` in the application
- **Your Downloads**: `/mnt/windows/Downloads/` in the application
- **Your Desktop**: `/mnt/windows/Desktop/` in the application
- **Project Data**: `/home/analyst/data/` (local data directory)

**File Dialog Navigation**: When opening files in the application, navigate to these mounted paths to access your Windows files and directories.

**Note**: You may see ALSA audio warnings in the console - these are normal in containerized environments and don't affect the core signal processing functionality. See the [Audio Support](#audio-support) section for audio setup if needed.

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
- **`run-gui-audio-windows.bat`** - Run with X11 GUI and PulseAudio support
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

## Windows File System Access

### Overview
The Docker container is configured to mount Windows directories so you can easily access your files from within the RF IQ Analyst application.

### Mounted Windows Directories
When the container runs, these Windows locations are available inside the application:

| Windows Location | Container Path | Description |
|-----------------|----------------|-------------|
| `C:\` | `/mnt/windows/C/` | Full C: drive access |
| `C:\Users\` | `/mnt/windows/Users/` | All user directories |
| `%USERPROFILE%\Documents` | `/mnt/windows/Documents/` | Your Documents folder |
| `%USERPROFILE%\Downloads` | `/mnt/windows/Downloads/` | Your Downloads folder |
| `%USERPROFILE%\Desktop` | `/mnt/windows/Desktop/` | Your Desktop |
| Local `./data/` | `/home/analyst/data/` | Project data directory |

### How to Open Windows Files
1. **Start the application** using `quick-start-windows.bat` or `run-gui-windows.bat`
2. **Open File Dialog** in the RF IQ Analyst application (File → Open)
3. **Navigate** to the mounted Windows paths:
   - Type `/mnt/windows/` in the location bar, or
   - Browse to `/mnt/windows/Documents/` for your Documents
   - Browse to `/mnt/windows/Downloads/` for Downloads
   - Browse to `/mnt/windows/Desktop/` for Desktop files
4. **Select your IQ data files** from any Windows location

### Example File Paths
- Opening files from Downloads: `/mnt/windows/Downloads/my_signal_data.iq`
- Opening files from Documents: `/mnt/windows/Documents/RF_Data/signal.vrt`
- Opening files from any drive: `/mnt/windows/C/Data/measurements/`

### Custom Directory Mounting
To mount additional Windows directories, edit the Docker run command or docker-compose.yml:

**Manual Docker Command:**
```cmd
docker run -it --rm ^
    -e DISPLAY=host.docker.internal:0.0 ^
    -v "D:\MySignalData:/mnt/windows/MySignalData" ^
    rf-iq-analyst:latest
```

**Docker Compose (add to volumes section):**
```yaml
volumes:
  - D:/MySignalData:/mnt/windows/MySignalData
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

### Windows Directory Access Issues
- **Cannot see Windows files**: Check Docker Desktop file sharing settings
  - Go to Docker Desktop → Settings → Resources → File Sharing
  - Ensure C: drive is shared for Docker
- **Permission denied**: Run Docker Desktop as Administrator if needed
- **Path not found**: Verify paths exist and use forward slashes in container paths
- **Test directory mounting**: Run `test-windows-mount.bat` to verify setup

## Audio Support

### Understanding ALSA Warnings
The ALSA (Advanced Linux Sound Architecture) warnings you see are normal in Docker containers:
```
ALSA lib confmisc.c:855:(parse_card) cannot find card '0'
ALSA lib pcm.c:2664:(snd_pcm_open_noupdate) Unknown PCM default
Playback open error: No such file or directory
```

These occur because:
- The container doesn't have direct access to host audio hardware
- Qt applications try to initialize audio systems even if not using audio
- The warnings don't affect signal processing or analysis functionality

### Audio Setup Options

#### Option 1: Ignore Audio (Recommended for Signal Processing)
Use the standard script - audio warnings are harmless:
```cmd
run-gui-windows.bat
```

#### Option 2: PulseAudio Setup (Advanced Users)
For full audio support, use the enhanced script:
```cmd
run-gui-audio-windows.bat
```

**PulseAudio Setup Requirements**:
1. **Windows 11 with WSL2**: Use WSLg built-in audio
2. **Windows 10**: Install PulseAudio for Windows
   - Download from: https://www.freedesktop.org/wiki/Software/PulseAudio/Ports/Windows/Support/
   - Configure network access on port 4713
3. **Alternative**: Use WSL2 with PulseAudio bridge

#### Option 3: Docker Compose with Audio
```cmd
# Basic audio support
docker-compose up rf-iq-analyst

# WSLg audio support (Windows 11)
docker-compose up rf-iq-analyst-wslg
```

### Audio-Related Environment Variables
- **`XDG_RUNTIME_DIR`**: Set to `/tmp/runtime-analyst` to suppress XDG warnings
- **`PULSE_SERVER`**: PulseAudio server address (e.g., `host.docker.internal:4713`)
- **`PULSE_RUNTIME_PATH`**: WSLg PulseAudio socket path
- **`PULSE_CLIENTCONFIG`**: PulseAudio client configuration

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
The container now automatically mounts common Windows directories for easy file access:

**Pre-configured Mounts:**
- **Project Data**: `./data` → `/home/analyst/data/` (for saving work)
- **Windows C: Drive**: `C:\` → `/mnt/windows/C/` (full drive access)
- **User Documents**: `%USERPROFILE%\Documents` → `/mnt/windows/Documents/`
- **User Downloads**: `%USERPROFILE%\Downloads` → `/mnt/windows/Downloads/`
- **User Desktop**: `%USERPROFILE%\Desktop` → `/mnt/windows/Desktop/`

**Additional Custom Mounts:**
```cmd
# Run with custom directory mount
docker run --rm -e DISPLAY=host.docker.internal:0.0 -e QT_X11_NO_MITSHM=1 ^
    -v "D:\MyRFData:/mnt/windows/MyRFData" ^
    -v "E:\Measurements:/mnt/windows/Measurements" ^
    rf-iq-analyst:latest
```

### Supported File Formats
- **IQ Data**: Complex binary files, VITA 49 (VRT) format
- **Training Data**: NumPy (.npy) files for ML models
- **Models**: TensorFlow SavedModel format
- **Export**: CSV, JSON for analysis results

### Data Locations in Container
- **Application data**: `/home/analyst/data/` (local project data)
- **Windows C: drive**: `/mnt/windows/C/` (full Windows C: drive)
- **Windows user files**: 
  - Documents: `/mnt/windows/Documents/`
  - Downloads: `/mnt/windows/Downloads/`
  - Desktop: `/mnt/windows/Desktop/`
  - All users: `/mnt/windows/Users/`
- **ML models**: `/home/analyst/models/`
- **Python scripts**: `/usr/local/share/rf-iq-analyst/classifiers/`
- **Logs**: `/home/analyst/logs/`

### File Access Examples
**Opening Signal Files:**
1. Launch RF IQ Analyst application
2. Use File → Open dialog
3. Navigate to mounted Windows directories:
   ```
   /mnt/windows/Downloads/signal_data.iq
   /mnt/windows/Documents/RF_Measurements/test.vrt
   /mnt/windows/C/Data/recordings/measurement.bin
   ```

**Saving Analysis Results:**
- Save to project directory: `/home/analyst/data/results/`
- Export to Windows: `/mnt/windows/Documents/RF_Analysis/`

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
