sudo-g5k ipmitool sensor list | grep -i 'gpu'
sudo-g5k ipmitool sdr type temperature

# To extract a specific value:
sudo-g5k ipmitool sdr get "GPU1 Temp"
# Or raw: Change 89h to 0x89 here (is there an offset?):
sudo-g5k raw 0x04 0x2D 0x89

