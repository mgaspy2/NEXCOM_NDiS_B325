# NEXCOM NDiS B325 Setup

Automated setup script for configuring NEXCOM NDiS B325 as an Ubuntu server.

## Features

- Installs Nala package manager
- Configures Docker with user permissions
- Sets up UFW firewall (SSH + Wake-on-LAN)
- Deploys custom `.bashrc` and `.bash_aliases`
- Auto-clones repository to `~/Repos/NEXCOM_NDiS_B325`

## Usage

```bash
cd ./NEXCOM_NDiS_B325
chmod +x setup.sh
sudo ./setup.sh
```

The script will prompt for reboot after completion. Select `Y` to reboot immediately or `n` to reboot later.

## Requirements

- Fresh Ubuntu installation
- Root/sudo access
- Internet connection

## Post-Setup

After reboot, the repository will be available at `~/Repos/NEXCOM_NDiS_B325` with Docker group permissions active.
