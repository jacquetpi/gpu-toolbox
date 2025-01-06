#!/bin/bash
wget https://download.blender.org/release/BlenderBenchmark2.0/launcher/benchmark-launcher-cli-3.1.0-linux.tar.gz
tar -xvf benchmark-launcher-cli-3.1.0-linux.tar.gz

./benchmark-launcher-cli blender list
./benchmark-launcher-cli blender download 4.3.0
./benchmark-launcher-cli scenes download --blender-version 4.3.0 monster:

./benchmark-launcher-cli devices --blender-version 4.3.0

./benchmark-launcher-cli benchmark --blender-version 4.3.0 --device-type CPU --json monster
