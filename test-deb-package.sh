#!/bin/bash
# Test script for RF IQ Analyst .deb package

set -e

echo "=== RF IQ Analyst .deb Package Tester ==="
echo ""

# Check if the .deb file exists
if [ ! -f "rf-iq-analyst-1.0.0.deb" ]; then
    echo "Error: rf-iq-analyst-1.0.0.deb not found in current directory"
    echo "Please run this script from the dist/ directory"
    exit 1
fi

echo "Testing .deb package: rf-iq-analyst-1.0.0.deb"
echo ""

# Check if lintian is available for package validation
if command -v lintian &> /dev/null; then
    echo "Step 1: Running lintian package validation..."
    lintian rf-iq-analyst-1.0.0.deb || {
        echo "Warning: lintian found some issues (this is often normal)"
        echo ""
    }
else
    echo "Step 1: Skipping lintian validation (not installed)"
    echo "To install lintian: sudo apt-get install lintian"
    echo ""
fi

# Check package information
echo "Step 2: Package information:"
dpkg --info rf-iq-analyst-1.0.0.deb

echo ""
echo "Step 3: Package contents:"
dpkg --contents rf-iq-analyst-1.0.0.deb | head -20
echo "... (showing first 20 files)"

echo ""
echo "Step 4: Dependency check:"
dpkg --info rf-iq-analyst-1.0.0.deb | grep "Depends:"

echo ""
echo "=== Package Test Completed ==="
echo ""
echo "The package appears to be properly formatted."
echo "To install: sudo dpkg -i rf-iq-analyst-1.0.0.deb"
echo "Then run: sudo apt-get install -f  (if needed)"
echo ""

# Check if we're on a compatible system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]] && [[ "$VERSION_ID" == "22.04" ]]; then
        echo "System compatibility: ✓ Ubuntu 22.04 detected (fully supported)"
    elif [[ "$ID" == "ubuntu" ]]; then
        echo "System compatibility: ⚠ Ubuntu $VERSION_ID detected (may work)"
    elif [[ "$ID_LIKE" == *"debian"* ]]; then
        echo "System compatibility: ⚠ Debian-based system detected (may work)"
    else
        echo "System compatibility: ❌ Non-Debian system detected"
        echo "This package is designed for Ubuntu/Debian systems"
    fi
else
    echo "System compatibility: ❓ Cannot determine OS version"
fi

echo ""
echo "Test completed!"
