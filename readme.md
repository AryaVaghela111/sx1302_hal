# sx1302_hal (Modified)

A modified and enhanced version of the [Lora-net/sx1302_hal](https://github.com/Lora-net/sx1302_hal) library, specifically optimized for the **Waveshare SX1302 LoRaWAN Gateway HAT** and improved compatibility across different hardware configurations.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Hardware Compatibility](#hardware-compatibility)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)

## 🎯 Overview

This repository provides an enhanced version of the SX1302 Hardware Abstraction Layer (HAL) with modifications that improve stability, compatibility, and ease of use for LoRaWAN gateway deployments. The modifications are particularly focused on seamless integration with the Waveshare SX1302 LoRaWAN Gateway HAT.

## ✨ Features

- **Enhanced Compatibility**: Improved support for various hardware configurations
- **Waveshare SX1302 Optimization**: Specifically tested and optimized for Waveshare gateway HAT
- **Simplified Setup**: Streamlined installation and configuration process
- **Improved Stability**: Bug fixes and stability improvements over the original version
- **Better Documentation**: Comprehensive setup and troubleshooting guides
- **Automated Scripts**: Simplified build and deployment scripts

## 🔧 Hardware Compatibility

### Tested Platforms
- **Raspberry Pi 4 Model B** (Recommended)
- **Raspberry Pi 3 Model B+**
- **Raspberry Pi Zero 2 W**

### Supported Hardware
- **Waveshare SX1302 LoRaWAN Gateway HAT** (Primary target)
- **Generic SX1302-based LoRaWAN concentrators**

### Frequency Bands
- **EU868** (Europe)
- **US915** (North America)
- **AS923** (Asia-Pacific)
- **AU915** (Australia)
- **KR920** (South Korea)
- **IN865** (India)

## 📋 Prerequisites

Before installation, ensure your system meets the following requirements:

### System Requirements
- **Operating System**: Raspberry Pi OS (Debian-based) or Ubuntu
- **Architecture**: ARM64 or ARM32
- **Memory**: Minimum 512MB RAM (1GB+ recommended)
- **Storage**: At least 2GB free space

### Required Packages
```bash
sudo apt update
sudo apt install -y git build-essential pkg-config libftdi-dev
```

### Hardware Setup
1. Properly connect the SX1302 HAT to your Raspberry Pi
2. Ensure SPI is enabled in raspi-config
3. Verify GPIO connections are secure

## 🚀 Installation

### Step 1: Clone the Repository

```bash
# Navigate to your preferred directory
cd ~/Documents/

# Clone this modified repository
git clone https://github.com/AryaVaghela111/sx1302_hal.git
cd sx1302_hal
```

### Step 2: Build the Project

```bash
# Clean any previous builds
make clean

# Build all components
make all

# Verify build completed successfully
ls -la packet_forwarder/lora_pkt_fwd
```

### Step 3: Setup Reset Scripts

```bash
# Copy reset script to required directories
cp tools/reset_lgw.sh util_chip_id/
cp tools/reset_lgw.sh packet_forwarder/

# Make scripts executable
chmod +x util_chip_id/reset_lgw.sh
chmod +x packet_forwarder/reset_lgw.sh
```

### Step 4: Verify Installation

```bash
# Test chip ID utility
cd util_chip_id/
./chip_id

# You should see output showing the SX1302 chip information
```

## ⚙️ Configuration

### Basic Configuration

The packet forwarder uses JSON configuration files. Default configurations are provided for common setups:

```bash
cd packet_forwarder/

# List available configuration files
ls -la global_conf*.json local_conf*.json
```

### Frequency Band Configuration

Select the appropriate configuration for your region:

```bash
# For EU868 (Europe)
cp global_conf.json.sx1250.EU868 global_conf.json

# For US915 (North America)
cp global_conf.json.sx1250.US915 global_conf.json

# For AS923 (Asia-Pacific)
cp global_conf.json.sx1250.AS923 global_conf.json
```

### Network Server Configuration

Edit the `local_conf.json` file to configure your network server settings:

```json
{
    "gateway_conf": {
        "gateway_ID": "YOUR_GATEWAY_EUI",
        "server_address": "your.network.server",
        "serv_port_up": 1700,
        "serv_port_down": 1700,
        "keepalive_interval": 10,
        "stat_interval": 30,
        "push_timeout_ms": 100,
        "forward_crc_valid": true,
        "forward_crc_error": false,
        "forward_crc_disabled": false
    }
}
```

## 💻 Usage

### Running the Packet Forwarder

#### Basic Usage
```bash
cd ~/Documents/sx1302_hal/packet_forwarder/
./lora_pkt_fwd
```

#### With Specific Configuration
```bash
# Run with test configuration
./lora_pkt_fwd -c test_conf

# Run with custom configuration directory
./lora_pkt_fwd -c /path/to/your/config/
```

#### Running as a Service

Create a systemd service for automatic startup:

```bash
sudo nano /etc/systemd/system/lora-pkt-fwd.service
```

Add the following content:

```ini
[Unit]
Description=LoRa Packet Forwarder
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/Documents/sx1302_hal/packet_forwarder
ExecStart=/home/pi/Documents/sx1302_hal/packet_forwarder/lora_pkt_fwd
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable lora-pkt-fwd
sudo systemctl start lora-pkt-fwd
```

### Monitoring

#### Check Service Status
```bash
sudo systemctl status lora-pkt-fwd
```

#### View Logs
```bash
# Real-time logs
sudo journalctl -u lora-pkt-fwd -f

# Recent logs
sudo journalctl -u lora-pkt-fwd --since "1 hour ago"
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Issue: "No SX1302 chip detected"
**Solution:**
1. Check hardware connections
2. Verify SPI is enabled: `sudo raspi-config` → Interface Options → SPI → Enable
3. Reboot the system: `sudo reboot`

#### Issue: "Permission denied" errors
**Solution:**
```bash
# Add user to gpio group
sudo usermod -a -G gpio $USER

# Logout and login again, or reboot
```

#### Issue: Build failures
**Solution:**
```bash
# Install missing dependencies
sudo apt install -y build-essential pkg-config libftdi-dev

# Clean and rebuild
make clean
make all
```

#### Issue: Packet forwarder crashes
**Solution:**
1. Check configuration files for syntax errors
2. Verify frequency band matches your region
3. Check system logs: `dmesg | tail -50`

### Debug Mode

Run the packet forwarder in debug mode for detailed logging:

```bash
./lora_pkt_fwd -d
```

### Hardware Testing

Test your hardware setup:

```bash
# Test chip communication
cd util_chip_id/
./chip_id

# Test SPI communication
cd ../util_spi_stress/
./spi_stress
```

## 📚 Additional Resources

### Official Documentation
- **Waveshare SX1302 HAT Wiki**: [https://www.waveshare.com/wiki/SX1302_LoRaWAN_Gateway_HAT](https://www.waveshare.com/wiki/SX1302_LoRaWAN_Gateway_HAT)
- **Original SX1302 HAL**: [https://github.com/Lora-net/sx1302_hal](https://github.com/Lora-net/sx1302_hal)
- **LoRaWAN Specification**: [https://lora-alliance.org/wp-content/uploads/2020/11/lorawantm_specification_-v1.0.3.pdf](https://lora-alliance.org/wp-content/uploads/2020/11/lorawantm_specification_-v1.0.3.pdf)

### Community Support
- **LoRaWAN Community**: [https://lora-developers.semtech.com/](https://lora-developers.semtech.com/)
- **Raspberry Pi Forums**: [https://www.raspberrypi.org/forums/](https://www.raspberrypi.org/forums/)

## 🤝 Contributing

We welcome contributions to improve this modified version! Here's how you can help:

### Reporting Issues
1. Check existing issues before creating new ones
2. Provide detailed system information
3. Include error logs and configuration files
4. Describe steps to reproduce the problem

### Submitting Pull Requests
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/improvement`
3. Make your changes with clear commit messages
4. Test thoroughly on actual hardware
5. Submit a pull request with detailed description

### Development Guidelines
- Follow the existing code style
- Add comments for complex modifications
- Test on multiple hardware configurations
- Update documentation as needed

## 📄 License

This project inherits the license from the original [Lora-net/sx1302_hal](https://github.com/Lora-net/sx1302_hal) repository. Please refer to the original repository for license details.

## 🙏 Credits

- **Original Project**: [Lora-net/sx1302_hal](https://github.com/Lora-net/sx1302_hal) by Semtech Corporation
- **Hardware Platform**: [Waveshare SX1302 LoRaWAN Gateway HAT](https://www.waveshare.com/sx1302-lorawan-gateway-hat.htm)
- **Modifications**: [Arya Vaghela](https://github.com/AryaVaghela111)

## 📞 Support

For support and questions:

1. **Hardware Issues**: Refer to [Waveshare documentation](https://www.waveshare.com/wiki/SX1302_LoRaWAN_Gateway_HAT)
2. **Software Issues**: Create an issue in this repository
3. **General LoRaWAN Questions**: Visit [LoRa Developer Portal](https://lora-developers.semtech.com/)

---

**⚠️ Important Notice**: When following any external setup guides, always use this repository instead of the original for the modified features and improvements.

**Happy LoRaWAN Gateway Development! 📡**