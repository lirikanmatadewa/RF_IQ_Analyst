# Multi-stage Docker build for RF IQ Analyst
# Stage 1: Build environment with all dependencies
FROM ubuntu:22.04 AS builder

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic build tools and Qt
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    pkg-config \
    qtbase5-dev \
    qttools5-dev \
    qt5-qmake \
    libqt5widgets5 \
    libqt5gui5 \
    libqt5core5a \
    libqt5network5 \
    libqt5printsupport5 \
    && rm -rf /var/lib/apt/lists/*

# Install Python and ML dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python ML packages
RUN pip3 install --no-cache-dir \
    tensorflow==2.12.0 \
    numpy \
    scikit-learn \
    && ln -s /usr/bin/python3 /usr/bin/python

# Install signal processing and math libraries
RUN apt-get update && apt-get install -y \
    libfftw3-dev \
    libfftw3-single3 \
    libboost-all-dev \
    libopencv-dev \
    libasound2-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install liquid-dsp from source (not available in Ubuntu repos)
WORKDIR /tmp
RUN git clone https://github.com/jgaeddert/liquid-dsp.git && \
    cd liquid-dsp && \
    ./bootstrap.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd .. && rm -rf liquid-dsp

# Optional: Install CUDA support (uncomment if needed)
# RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
#     dpkg -i cuda-keyring_1.0-1_all.deb && \
#     apt-get update && \
#     apt-get -y install cuda-toolkit-11-8 && \
#     rm cuda-keyring_1.0-1_all.deb

# Set working directory for the project
WORKDIR /app

# Copy the project files
COPY . .

# Create build script
RUN echo '#!/bin/bash' > build.sh && \
    echo 'set -e' >> build.sh && \
    echo '' >> build.sh && \
    echo 'echo "Building RF IQ Analyst..."' >> build.sh && \
    echo '' >> build.sh && \
    echo '# Create build directory' >> build.sh && \
    echo 'mkdir -p build' >> build.sh && \
    echo '' >> build.sh && \
    echo '# Build dependencies in correct order' >> build.sh && \
    echo 'echo "Building qvrt_util library..."' >> build.sh && \
    echo 'cd qvrt_lib/qvrt_util' >> build.sh && \
    echo 'qmake qvrt_util.pro CONFIG+=release "INCLUDEPATH+=/usr/local/include" "LIBS+=-L/usr/local/lib"' >> build.sh && \
    echo 'make -j$(nproc)' >> build.sh && \
    echo 'cd ../..' >> build.sh && \
    echo '' >> build.sh && \
    echo 'echo "Building libsdrkit library..."' >> build.sh && \
    echo 'cd libsdrkit' >> build.sh && \
    echo 'qmake libsdrkit.pro CONFIG+=release "INCLUDEPATH+=/usr/local/include" "LIBS+=-L/usr/local/lib"' >> build.sh && \
    echo 'make -j$(nproc)' >> build.sh && \
    echo 'cd ..' >> build.sh && \
    echo '' >> build.sh && \
    echo 'echo "Building main application..."' >> build.sh && \
    echo 'cd analyst/Analyst' >> build.sh && \
    echo 'qmake Analyst.pro CONFIG+=release "INCLUDEPATH+=/usr/local/include" "LIBS+=-L/usr/local/lib"' >> build.sh && \
    echo 'make -j$(nproc)' >> build.sh && \
    echo 'cd ../..' >> build.sh && \
    echo '' >> build.sh && \
    echo 'echo "Build completed successfully!"' >> build.sh && \
    echo 'echo "Executable location: $(find . -name "Analyst.gui" -type f)"' >> build.sh && \
    chmod +x build.sh

# Build the project
RUN ./build.sh

# Stage 2: Runtime environment (smaller image)
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libqt5widgets5 \
    libqt5gui5 \
    libqt5core5a \
    libqt5network5 \
    libqt5printsupport5 \
    libfftw3-single3 \
    libboost-system1.74.0 \
    libboost-filesystem1.74.0 \
    libboost-thread1.74.0 \
    libboost-date-time1.74.0 \
    libboost-chrono1.74.0 \
    libopencv-core4.5d \
    libopencv-imgproc4.5d \
    libopencv-highgui4.5d \
    libopencv-photo4.5d \
    libasound2 \
    zlib1g \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python ML packages for runtime
RUN pip3 install --no-cache-dir \
    tensorflow==2.12.0 \
    numpy \
    scikit-learn \
    && ln -s /usr/bin/python3 /usr/bin/python

# Copy liquid-dsp library from builder stage
COPY --from=builder /usr/local/lib/libliquid* /usr/local/lib/
COPY --from=builder /usr/local/include/liquid/ /usr/local/include/liquid/
RUN ldconfig

# Copy the built application
COPY --from=builder /app/analyst/Analyst/Analyst.gui /usr/local/bin/rf-iq-analyst

# Copy Python classifier scripts and templates
COPY --from=builder /app/analyst/Analyst/classifiers/ /usr/local/share/rf-iq-analyst/classifiers/

# Set up environment for GUI applications (if running with X11 forwarding)
ENV QT_X11_NO_MITSHM=1
ENV DISPLAY=:0

# Create a non-root user
RUN useradd -m -s /bin/bash analyst
USER analyst
WORKDIR /home/analyst

# Default command
CMD ["/usr/local/bin/rf-iq-analyst"]
