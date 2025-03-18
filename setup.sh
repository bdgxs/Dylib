#!/bin/bash

# Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y git curl ldid wget dpkg-dev make perl zip unzip

# Clone Theos repository
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos

# Set THEOS environment variable and update PATH
echo 'export THEOS=/opt/theos' >> ~/.bashrc
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Create the working directory
sudo mkdir -p /Dylib

# Change to the working directory
cd /Dylib

# Install any other needed dependencies (uncomment and modify as needed)
# sudo apt-get install -y <your-library>