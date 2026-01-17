#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (sudo ./setup.sh)" 
   exit 1
fi

# Detect actual user to fix permissions
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

echo "Running NEXCOM NDiS B325 setup for user: $REAL_USER ($USER_HOME)"

# 1. Install Nala
    echo "[1/7] Installing Nala..."
    apt-get update && apt-get install -y nala

# 2. Install utilities
    echo "[2/7] Installing utilities..."
    nala update && nala install -y git

# 3. Setup Docker repo and install
    echo "[3/7] Setting up Docker..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

    nala update && nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group
    usermod -aG docker "$REAL_USER"

    # 4. Setup security
    echo "[4/7] Setting up security..."
    ufw allow ssh

    # Wake On LAN
    ufw allow 7/udp
    ufw allow 9/udp

    ufw --force enable

# 5. Overwrite config files (.bashrc, .bash_aliases)
    echo "[5/7] Overwriting configs from $SCRIPT_DIR..."

    # Backup existing files
    [ -f "$USER_HOME/.bashrc" ] && cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.bak"
    [ -f "$USER_HOME/.bash_aliases" ] && cp "$USER_HOME/.bash_aliases" "$USER_HOME/.bash_aliases.bak"

    # Copy new files if they exist in script directory
    if [ -f "$SCRIPT_DIR/.bashrc" ]; then
        cp "$SCRIPT_DIR/.bashrc" "$USER_HOME/.bashrc"
        chown "$REAL_USER:$REAL_USER" "$USER_HOME/.bashrc"
        echo " -> .bashrc updated"
    else
        echo " -> Warning: .bashrc not found in script directory."
    fi

    if [ -f "$SCRIPT_DIR/.bash_aliases" ]; then
        cp "$SCRIPT_DIR/.bash_aliases" "$USER_HOME/.bash_aliases"
        chown "$REAL_USER:$REAL_USER" "$USER_HOME/.bash_aliases"
        echo " -> .bash_aliases updated"
    else
        echo " -> Warning: .bash_aliases not found in script directory."
    fi

# 6. Create Repos dir
    echo "[6/7] Setting up ~/Repos..."
    # Check if script is not in ~/Repos/NEXCOM_NDiS_B325/
    TARGET_DIR="$USER_HOME/Repos/NEXCOM_NDiS_B325"
    if [[ "$SCRIPT_DIR" != "$TARGET_DIR" ]]; then
        echo ""
        echo "Script is not running from $TARGET_DIR"
        echo "Cloning repository in ~/Repos..."
        
        # Create Repos directory if it doesn't exist
        mkdir -p "$USER_HOME/Repos"
        chown "$REAL_USER:$REAL_USER" "$USER_HOME/Repos"
        
        # Clone repository if it doesn't exist
        if [ ! -d "$TARGET_DIR" ]; then
            echo "Cloning repository..."
            su - "$REAL_USER" -c "cd ~/Repos && git clone https://github.com/mgaspy2/NEXCOM_NDiS_B325.git"
            echo "Repository cloned to $TARGET_DIR"
        else
            echo "Repository already exists at $TARGET_DIR"
        fi
        
        # Mark current directory for deletion after reboot
        OLD_DIR="$SCRIPT_DIR"
        echo "Current directory $OLD_DIR will be deleted after reboot"
    fi

# 7. Cleanup and reboot
    echo "[7/7] Cleaning up..."
    nala autoremove -y

    echo "Setup Complete!"
    echo "A reboot is required for Docker group changes to take effect."

    # Prompt for reboot instead of immediate action
    read -p "Do you want to reboot now? [Y/n] " -n 1 -r
    echo

    # Delete old directory if it's different from target
    if [[ -n "$OLD_DIR" ]] && [[ "$OLD_DIR" != "$TARGET_DIR" ]]; then
        echo "Removing old directory: $OLD_DIR"
        rm -rf "$OLD_DIR"
    fi

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Rebooting..."
        reboot
    else
        cd "$TARGET_DIR"
        echo "Reboot skipped. Please remember to reboot manually later."
    fi
