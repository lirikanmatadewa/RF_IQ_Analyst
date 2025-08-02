# RF IQ Analyst - User Guide

## Getting Started

### First Launch
1. Follow the Docker setup in [DOCKER-README.md](../DOCKER-README.md)
2. Run `quick-start-windows.bat`
3. The application will open in a new window

### Interface Overview
The RF IQ Analyst interface consists of several main areas:
- **Menu Bar**: File operations, tools, and settings
- **Signal Display**: Time and frequency domain visualizations
- **Control Panel**: Parameter controls and analysis tools
- **Status Bar**: System status and progress indicators

## Working with IQ Data

### Loading Data Files
1. **File → Open** or `Ctrl+O`
2. Select your IQ data file (supported formats: binary, VRT)
3. Configure sample rate and data format if prompted
4. Data will display in time and frequency domains

### Supported File Formats
- **Binary IQ**: 16-bit or 32-bit complex samples
- **VITA 49 (VRT)**: Standard packet format
- **Custom formats**: Configurable through settings

### Data Visualization
- **Time Domain**: I/Q amplitude and phase plots
- **Frequency Domain**: FFT spectrum analysis
- **Waterfall**: Frequency vs. time spectrogram
- **Constellation**: I/Q scatter plot

## Signal Analysis Tools

### Spectrum Analysis
1. Load your IQ data
2. **Tools → Spectrum Analyzer**
3. Adjust FFT size, window type, and averaging
4. Use markers to measure specific frequencies

### Signal Detection
1. **Tools → Signal Detector**
2. Set detection thresholds
3. Configure frequency ranges
4. View detected signals in results panel

### Demodulation
1. Select signal of interest
2. **Tools → Demodulator**
3. Choose modulation type (AM, FM, PSK, QAM, etc.)
4. Configure demodulation parameters

## Machine Learning Classification

### Training Models

#### Preparing Training Data
1. Collect signal samples for each class
2. Save samples as NumPy (.npy) files
3. Organize in folders by signal type:
   ```
   training_data/
   ├── Signal_Type_A/
   │   ├── sample1.npy
   │   └── sample2.npy
   ├── Signal_Type_B/
   │   ├── sample1.npy
   │   └── sample2.npy
   └── ...
   ```

#### Training Process
1. **Classifier → Create New Classifier**
2. Select training data directory
3. Choose classification method:
   - **Raw IQ**: Train on time-domain samples
   - **FFT**: Train on frequency-domain features
4. Configure training parameters:
   - Batch size (5-50, depending on RAM)
   - Validation split (typically 20%)
   - Number of epochs
5. Click **Start Training**
6. Monitor progress via UDP logging

#### Training Parameters
- **Batch Size**: 5-10 for systems with 8GB RAM, 20+ for 16GB+
- **Epochs**: Start with 50-100, adjust based on convergence
- **Learning Rate**: Default 0.001, reduce if training is unstable
- **Network Architecture**: Configurable in Python scripts

### Using Trained Models

#### Classification Process
1. **Classifier → Load Model**
2. Select your trained model
3. Load unknown signal data
4. **Classifier → Classify Signal**
5. View classification results and confidence scores

#### Interpreting Results
- **Confidence Score**: 0-100% certainty of classification
- **Class Probabilities**: Distribution across all trained classes
- **Feature Visualization**: Input features used for classification

### Model Management
- **Save Models**: Automatically saved during training
- **Export Models**: Copy to external storage for backup
- **Model Versioning**: Track different training sessions
- **Performance Metrics**: Accuracy, precision, recall statistics

## Advanced Features

### Batch Processing
1. **Tools → Batch Processor**
2. Select multiple files or directories
3. Configure processing pipeline
4. Run automated analysis on large datasets

### Custom Signal Processing
1. **Tools → Signal Processor**
2. Configure custom filter chains
3. Apply gain, filtering, and transformation
4. Export processed signals

### GPS Integration
- Import GPS data with VRT files
- Geolocation of signal sources
- Time-synchronized analysis

### Plugin System
- Load custom processing plugins
- Extend functionality with user code
- Python and C++ plugin interfaces

## Keyboard Shortcuts

### File Operations
- `Ctrl+O`: Open file
- `Ctrl+S`: Save project
- `Ctrl+E`: Export data
- `Ctrl+Q`: Quit application

### Navigation
- `Space`: Play/pause playback
- `Left/Right Arrows`: Seek in time
- `Up/Down Arrows`: Zoom frequency
- `Page Up/Down`: Scroll through data

### Analysis
- `F1`: Quick spectrum analysis
- `F2`: Signal detection
- `F3`: Start classification
- `F4`: Export results

## Tips and Best Practices

### Performance Optimization
- **RAM Usage**: Close unused visualizations to save memory
- **GPU Acceleration**: Enable CUDA if available (requires NVIDIA GPU)
- **File Caching**: Enable disk caching for large files
- **Parallel Processing**: Use multiple CPU cores for batch jobs

### Data Quality
- **Sample Rate**: Ensure adequate Nyquist sampling
- **Dynamic Range**: Check for clipping or quantization noise
- **Calibration**: Verify frequency and amplitude accuracy
- **Timestamps**: Ensure accurate timing for analysis

### ML Training Tips
- **Data Balance**: Equal samples per class for best results
- **Data Diversity**: Include variations in SNR, frequency offset
- **Validation**: Always use separate test data
- **Overfitting**: Monitor validation loss during training

### Troubleshooting
- **Out of Memory**: Reduce batch size or FFT length
- **Slow Performance**: Check Docker resource allocation
- **Classification Errors**: Verify training data quality
- **GUI Issues**: Restart X server (VcXsrv)

## Example Workflows

### Workflow 1: Basic Signal Analysis
1. Load IQ file → Spectrum analysis → Mark signals → Export results

### Workflow 2: ML Classification Setup
1. Collect training data → Organize by class → Train model → Validate performance

### Workflow 3: Automated Processing
1. Configure batch processor → Set input directory → Run analysis → Review results

### Workflow 4: Real-time Monitoring
1. Configure signal detector → Set thresholds → Monitor live → Alert on detection

## Data Export and Reporting

### Export Formats
- **CSV**: Measurement data and results
- **JSON**: Structured analysis results
- **Images**: Plots and spectrograms
- **Reports**: Automated analysis summaries

### Custom Reports
1. **Tools → Report Generator**
2. Select analysis results
3. Configure report template
4. Generate PDF or HTML report

For technical support and advanced configuration, see [TECHNICAL-REFERENCE.md](TECHNICAL-REFERENCE.md).
