# RF IQ Analyst - Technical Reference

## Architecture Overview

### System Components
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Qt GUI        │    │   libsdrkit      │    │   Python ML     │
│   (Frontend)    │◄──►│   (Core Engine)  │◄──►│   (Classifiers) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   qvrt_util     │    │   Signal Proc.   │    │   TensorFlow    │
│   (VRT Support) │    │   Libraries      │    │   (ML Engine)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Library Dependencies
- **Qt5**: GUI framework and core utilities
- **FFTW3**: Fast Fourier Transform calculations
- **Boost**: C++ utility libraries
- **OpenCV**: Computer vision and image processing
- **liquid-dsp**: Digital signal processing primitives
- **TensorFlow**: Machine learning framework
- **NumPy**: Numerical computing for Python
- **scikit-learn**: Machine learning utilities

## Core Modules

### qvrt_util Library
**Purpose**: VITA 49 (VRT) packet processing and GPS support

**Key Classes**:
- `VRTReader`: VRT packet parsing and validation
- `VRTWriter`: VRT packet generation and output
- `GPSReader`: GPS metadata extraction
- `TimeStamper`: Precision timing utilities

**File Formats Supported**:
- VITA 49.0/49.2 standard packets
- Context packets with GPS data
- Signal data packets (16-bit, 32-bit complex)

### libsdrkit Library
**Purpose**: Core signal processing and analysis engine

**Key Classes**:
```cpp
class SignalProcessor {
    // Core signal processing pipeline
    void setInput(ComplexSamples* samples);
    void addFilter(FilterBase* filter);
    ComplexSamples* process();
};

class SpectrumAnalyzer {
    // FFT-based spectrum analysis
    void setFFTSize(int size);
    void setWindowType(WindowType type);
    PowerSpectrum* compute(ComplexSamples* input);
};

class SignalDetector {
    // Automatic signal detection
    void setThreshold(double threshold_db);
    SignalList* detect(PowerSpectrum* spectrum);
};

class Classifier {
    // ML classification interface
    bool trainModel(QString dataPath, ClassifierMethod method);
    ClassificationResult* classify(ComplexSamples* signal);
};
```

**Signal Processing Pipeline**:
1. **Input Stage**: File reading, sample rate conversion
2. **Preprocessing**: Filtering, gain control, windowing
3. **Analysis**: FFT, spectrum estimation, feature extraction
4. **Detection**: Threshold-based signal detection
5. **Classification**: ML-based signal identification
6. **Output**: Results formatting and export

### Python ML Module
**Purpose**: TensorFlow-based machine learning for signal classification

**Core Scripts**:
- `trainIQ.py`: Raw IQ data model training
- `trainFFT.py`: Frequency domain model training
- `predictIQ.py`: IQ-based signal classification
- `predictFFT.py`: FFT-based signal classification
- `datasetIQ.py`/`datasetFFT.py`: Data loading utilities

**ML Architecture**:
```python
# Convolutional Neural Network for IQ Classification
model = tf.keras.Sequential([
    tf.keras.layers.Conv2D(32, (3, 3), activation='relu'),
    tf.keras.layers.MaxPooling2D((2, 2)),
    tf.keras.layers.Conv2D(64, (3, 3), activation='relu'),
    tf.keras.layers.MaxPooling2D((2, 2)),
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dense(num_classes, activation='softmax')
])
```

## Data Flow Architecture

### IQ Data Processing
```
Raw IQ File
    │
    ▼
┌─────────────────┐
│  File Reader    │ ── Sample Rate: 1-100 MHz
│  (qvrt_util)    │ ── Format: 16/32-bit complex
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  Preprocessor   │ ── Filtering: LP/HP/BP
│  (libsdrkit)    │ ── Gain: Auto/Manual
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  FFT Engine     │ ── Size: 256-65536 points
│  (FFTW3)        │ ── Window: Hann/Hamming/etc
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  Feature Extract│ ── Time domain features
│  (libsdrkit)    │ ── Frequency features
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  ML Classifier  │ ── TensorFlow CNN
│  (Python)       │ ── UDP Communication
└─────────────────┘
```

### ML Training Pipeline
```
Training Data (.npy files)
    │
    ▼ 
┌─────────────────┐
│  Data Loader    │ ── Validation split: 20%
│  (datasetIQ.py) │ ── Shuffling & batching
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  Model Training │ ── Epochs: 50-200
│  (trainIQ.py)   │ ── Learning rate: 0.001
└─────────────────┘
    │
    ▼
┌─────────────────┐
│  Model Save     │ ── TensorFlow SavedModel
│  (TensorFlow)   │ ── Metrics logging
└─────────────────┘
```

## Communication Protocols

### C++ ↔ Python Interface
**Method**: QProcess with UDP sockets for bidirectional communication

**Training Communication** (Port 5005):
```cpp
// C++ side
QProcess* trainProcess = new QProcess();
trainProcess->start("python trainIQ.py");

QUdpSocket* socket = new QUdpSocket();
socket->bind(QHostAddress::LocalHost, 5005);
```

```python
# Python side
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
progress_data = f"epoch:{epoch},loss:{loss:.4f},accuracy:{acc:.4f}"
sock.sendto(progress_data.encode(), ("127.0.0.1", 5005))
```

**Classification Communication** (Port 5006):
```cpp
// C++ sends signal data file path
QString command = "python predictIQ.py " + signalFilePath;
process->start(command);

// Python returns classification results via UDP
sock.sendto(f"class:{predicted_class},confidence:{confidence:.2f}", 
           ("127.0.0.1", 5006))
```

### File Formats

#### NumPy Data Format (.npy)
```python
# IQ data storage format
iq_data = np.array([[I1, Q1], [I2, Q2], ...], dtype=np.float32)
iq_reshaped = iq_data.reshape(500, 128, 1)  # 500 samples, 128 complex pairs
np.save('signal_sample.npy', iq_reshaped)
```

#### VRT Packet Structure
```
VRT Header (32 bits)
├── Packet Type (4 bits)
├── Class ID (1 bit) 
├── Trailer (1 bit)
├── Packet Count (4 bits)
├── Packet Size (16 bits)
└── Stream ID (32 bits)

Timestamp (64 bits)
├── Integer Seconds (32 bits)
└── Fractional Seconds (32 bits)

Payload (Variable)
├── Complex IQ Samples
└── Context Information
```

## Configuration Management

### Qt Application Settings
**Location**: `~/.config/RF_IQ_Analyst/settings.ini`

**Key Parameters**:
```ini
[General]
DefaultSampleRate=1000000
MaxFileSize=1073741824
TempDirectory=/tmp/rf-iq-analyst

[Display]
FFTSize=2048
WindowType=Hann
SpectrumAveraging=10

[ML]
PythonPath=/usr/bin/python3
ModelDirectory=./models
BatchSize=10
DefaultMethod=IQ
```

### Docker Environment Variables
```dockerfile
ENV QT_X11_NO_MITSHM=1          # X11 optimization
ENV DISPLAY=:0                   # X11 display target
ENV PYTHONPATH=/usr/local/lib    # Python module path
ENV TF_CPP_MIN_LOG_LEVEL=2       # TensorFlow logging
```

## Performance Optimization

### Memory Management
**C++ Side**:
- Smart pointers for automatic cleanup
- Memory pools for frequent allocations
- Streaming for large file processing

**Python Side**:
- NumPy arrays for efficient computation
- Batch processing to limit memory usage
- Model optimization and quantization

### Computational Optimization
**FFT Performance**:
- FFTW3 with SIMD optimization
- Multi-threaded FFT computation
- Cached FFT plans for repeated sizes

**ML Performance**:
- TensorFlow GPU acceleration (if available)
- Model inference optimization
- Batch prediction for multiple signals

### Docker Resource Allocation
**Recommended Settings**:
```yaml
# docker-compose.yml
services:
  rf-iq-analyst:
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4.0'
        reservations:
          memory: 4G
          cpus: '2.0'
```

## Build System Details

### qmake Configuration
**Project Structure**:
```
RF_IQ_Analyst/
├── qvrt_lib/qvrt_util/qvrt_util.pro    # VRT library
├── libsdrkit/libsdrkit.pro             # Core processing
└── analyst/Analyst/Analyst.pro         # Main application
```

**Build Dependencies**:
```pro
# Analyst.pro
LIBS += -L../../../qvrt_lib/qvrt_util -lqvrt_util
LIBS += -L../../../libsdrkit -lsdrkit
LIBS += -lfftw3f -lfftw3 -lboost_system -lopencv_core
INCLUDEPATH += ../../../qvrt_lib/qvrt_util/include
INCLUDEPATH += ../../../libsdrkit
```

### Docker Build Process
1. **Base Image**: Ubuntu 22.04
2. **Development Tools**: GCC, CMake, Qt5 dev packages
3. **Signal Processing**: FFTW3, Boost, OpenCV installation
4. **liquid-dsp**: Source compilation and installation
5. **Python ML**: Python 3, TensorFlow, NumPy, scikit-learn
6. **Project Build**: qvrt_util → libsdrkit → main application
7. **Runtime Image**: Minimal runtime dependencies only

## API Reference

### Core Signal Processing APIs

#### ComplexSamples Class
```cpp
class ComplexSamples {
public:
    ComplexSamples(int size);
    void setSampleRate(double rate);
    std::complex<float>* data();
    int size() const;
    double sampleRate() const;
    
    // Signal operations
    void applyGain(double gain_db);
    void filterLowPass(double cutoff_hz);
    ComplexSamples* downsample(int factor);
};
```

#### FFTProcessor Class
```cpp
class FFTProcessor {
public:
    FFTProcessor(int fft_size);
    void setWindow(WindowType type);
    PowerSpectrum* computeSpectrum(ComplexSamples* input);
    ComplexSpectrum* computeFFT(ComplexSamples* input);
    
private:
    fftwf_plan forward_plan;
    fftwf_complex* fft_in;
    fftwf_complex* fft_out;
};
```

#### Classifier Class
```cpp
class Classifier : public QObject {
    Q_OBJECT
    
public:
    enum Method { eRawIQ, eFFT };
    
    bool startTraining(QString dataPath, Method method);
    bool classify(ComplexSamples* signal, QString& result);
    void stopTraining();
    
signals:
    void trainingProgress(int epoch, double loss, double accuracy);
    void classificationComplete(QString className, double confidence);
    
private:
    QProcess* m_trainProcess;
    QProcess* m_classifyProcess;
    QUdpSocket* m_trainingSocket;
    QUdpSocket* m_classifySocket;
};
```

### Python ML APIs

#### Dataset Loading
```python
def load_train_sets(train_path, classes, validation_size=0.2):
    """Load and split training data"""
    # Implementation details...
    return DataSet(train_x, train_y, valid_x, valid_y, test_x, test_y)

def read_test_set(test_path, classes):
    """Load test data for evaluation"""
    # Implementation details...
    return test_images, test_labels
```

#### Model Training
```python
def create_model(input_shape, num_classes):
    """Create CNN model architecture"""
    model = tf.keras.Sequential([
        tf.keras.layers.Reshape(input_shape),
        tf.keras.layers.Conv2D(32, (3, 3), activation='relu'),
        tf.keras.layers.MaxPooling2D((2, 2)),
        tf.keras.layers.Conv2D(64, (3, 3), activation='relu'),
        tf.keras.layers.MaxPooling2D((2, 2)),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dropout(0.5),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    return model
```

## Debugging and Diagnostics

### Log File Locations
**Container Paths**:
- Application logs: `/home/analyst/logs/analyst.log`
- Python ML logs: `/home/analyst/logs/ml.log`
- System logs: `/var/log/` (requires root access)

**Log Level Configuration**:
```cpp
// C++ logging
qSetLoggingRules("*=true");
qDebug() << "Signal processing started";
qWarning() << "Classification timeout";
qCritical() << "Memory allocation failed";
```

### Debug Build Configuration
```dockerfile
# Debug build with symbols
RUN qmake CONFIG+=debug "QMAKE_CXXFLAGS+=-g -O0"
RUN make -j$(nproc)

# GDB debugging support
RUN apt-get install -y gdb
```

### Performance Profiling
**Valgrind Memory Checking**:
```bash
docker run --rm -it rf-iq-analyst:latest bash
valgrind --tool=memcheck --leak-check=full /usr/local/bin/rf-iq-analyst
```

**CPU Profiling**:
```bash
# Install perf tools
apt-get install linux-perf
perf record -g /usr/local/bin/rf-iq-analyst
perf report
```

## Security Considerations

### Container Security
- Non-root user execution (`analyst` user)
- No privileged access required
- Read-only filesystem where possible
- Minimal attack surface (runtime image)

### Data Security
- No sensitive data in container images
- User data mounted as volumes
- Network isolation (only X11 forwarding)
- No external network access required

### X11 Security
- Local-only X11 forwarding
- VcXsrv access control disabled (required for container access)
- No persistent X11 authentication

For user documentation, see [USER-GUIDE.md](USER-GUIDE.md).
