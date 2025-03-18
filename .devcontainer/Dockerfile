name: Build iOS Tweak

on:
  push:
    branches:
      - main # Or your desired branch

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build Tweak (Docker)
        uses: docker://ghcr.io/kabiroberai/theos-docker:latest # or your own docker image
        with:
          args: make package

      - name: Upload .deb artifact
        uses: actions/upload-artifact@v3
        with:
          name: cpuinfo-tweak
          path: ./packages/*.deb