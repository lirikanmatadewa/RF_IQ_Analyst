#!/bin/bash
# Build script for creating RF IQ Analyst .deb package

set -e

echo "=== RF IQ Analyst .deb Package Builder ==="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

echo "Building RF IQ Analyst .deb package..."
echo ""

# Create dist directory if it doesn't exist
mkdir -p dist

# Build the Docker image and extract the .deb package
echo "Step 1: Building Docker image with .deb package..."
docker build -f Dockerfile.deb -t rf-iq-analyst-deb-builder:latest .

echo ""
echo "Step 2: Extracting .deb package and artifacts..."

# Create a temporary container to extract files
CONTAINER_ID=$(docker create rf-iq-analyst-deb-builder:latest)

# Extract the dist directory contents
docker cp ${CONTAINER_ID}:/dist/ ./

# Clean up the temporary container
docker rm ${CONTAINER_ID}

# Move contents from dist/dist to dist (Docker cp creates nested directory)
if [ -d "dist/dist" ]; then
    mv dist/dist/* dist/ 2>/dev/null || true
    rmdir dist/dist 2>/dev/null || true
fi

echo ""
echo "Step 3: Package build completed!"
echo ""
echo "Generated files in ./dist/:"
ls -la dist/

echo ""
echo "=== Installation Instructions ==="
echo ""
echo "To install the .deb package on Ubuntu/Debian:"
echo "  cd dist"
echo "  sudo ./install.sh"
echo ""
echo "Or manually:"
echo "  cd dist"
echo "  sudo dpkg -i rf-iq-analyst-1.0.0.deb"
echo "  sudo apt-get install -f  # if dependencies are missing"
echo ""
echo "To test the package:"
echo "  lintian dist/rf-iq-analyst-1.0.0.deb  # check package quality"
echo ""
echo "Package build completed successfully!"
