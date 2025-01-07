#!/bin/bash

# Dependencies
sudo apt install -y libxkbcommon-x11-0 libxrender1 libxi6

# Install
wget https://download.blender.org/release/BlenderBenchmark2.0/launcher/benchmark-launcher-cli-3.1.0-linux.tar.gz
tar -xvf benchmark-launcher-cli-3.1.0-linux.tar.gz

# Pre-fetch
./benchmark-launcher-cli blender list
./benchmark-launcher-cli blender download 4.3.0
./benchmark-launcher-cli scenes download --blender-version 4.3.0 monster

./benchmark-launcher-cli devices --blender-version 4.3.0

# Launch
./benchmark-launcher-cli benchmark --blender-version 4.3.0 --device-type OPTIX --json monster
