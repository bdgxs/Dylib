FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ldid \
    wget \
    dpkg-dev \
    make \
    perl \
    zip \
    unzip

# Install Theos
RUN git clone --recursive https://github.com/theos/theos.git /opt/theos
ENV THEOS /opt/theos
ENV PATH $THEOS/bin:$THEOS/bin:$PATH

# Create the working directory
RUN mkdir -p /Dylib

# Set the working directory
WORKDIR /Dylib

# Install any other needed dependencies.
# Example: If you need specific libraries for your tweak, install them here.
# RUN apt-get install -y <your-library>