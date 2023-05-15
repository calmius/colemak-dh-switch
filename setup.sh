#!/bin/sh
SERVICE_FILE="/etc/systemd/system/colemak-dh.service"
# Change path-to to current directory.
CONFIG_FILE="/path-to/colemak-dh-YOURLAYOUT"

# Load uinput kernel module to emulate input devices from userspace:
sudo modprobe uinput
# Add self to input and uinput groups:
sudo usermod -aG input $USER
sudo groupadd uinput
sudo usermod -aG uinput $USER
# Rules for misc devices (keyboard, mouse ...)
sudo echo 'KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput"' | sudo tee /etc/udev/rules.d/90-uinput.rules
# This seems to be needed because uinput isn't compiled as a loadable module these days:
sudo echo uinput | sudo tee /etc/modules-load.d/uinput.conf
# Enable at startup:
# /ect/systemd/system/colemak-dh.service
sudo cat > "$SERVICE_FILE" << EOF
[Unit]
Description=kmonad keyboard config

[Service]
Restart=always
RestartSec=3
ExecStart=/usr/bin/kmonad "$CONFIG_FILE"
Nice=-20

[Install]
WantedBy=default.target
EOF
# Set permission for only root to write to file
sudo chmod 644 "$SERVICE_FILE"
# Reload the systemd manager configuration
sudo systemctl daemon-reload
# Run at startup
sudo systemctl enable colemak-dh.service
