# 🔀 DNS Switcher for Linux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)

A simple and interactive script to switch from Yandex Cloud DNS to Google DNS, Cloudflare DNS, or custom DNS servers on Linux systems using systemd-resolved.

Perfect for Yandex Cloud VMs and other Linux systems that use systemd-resolved for DNS management.

## ✨ Features

- 🎯 **Interactive menu** - Choose from popular DNS providers or set custom servers
- 🔐 **Automatic backup** - All changes are backed up before modification
- ✅ **Verification** - Automatically tests DNS resolution after configuration
- 🔄 **Persistent** - Changes survive system reboots
- 🗑️ **Easy rollback** - Uninstaller to restore original settings
- 🎨 **Colorful output** - Clear, easy-to-read console output
- 🛡️ **Safe** - Creates backups and validates configuration

## 📋 Supported DNS Providers

1. **Google DNS + Cloudflare DNS** (default)
   - Primary: `8.8.8.8`, `8.8.4.4`, `1.1.1.1`, `1.0.0.1`
   - Fallback: `9.9.9.9` (Quad9)

2. **Google DNS only**
   - Primary: `8.8.8.8`, `8.8.4.4`
   - Fallback: `9.9.9.9`

3. **Cloudflare DNS only**
   - Primary: `1.1.1.1`, `1.0.0.1`
   - Fallback: `9.9.9.9`

4. **Quad9 DNS**
   - Primary: `9.9.9.9`, `149.112.112.112`
   - Fallback: `1.1.1.1`

5. **Custom DNS servers**
   - Set your own DNS servers

## 🚀 Quick Start

### One-line Installation and Execution

```bash
wget "https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh" -O dns-switcher.sh && chmod +x dns-switcher.sh && sudo bash dns-switcher.sh
```

### Manual Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh
```

2. Make it executable:
```bash
chmod +x dns-switcher.sh
```

3. Run with sudo:
```bash
sudo ./dns-switcher.sh
```

## 📖 Usage

### Installing/Changing DNS

```bash
sudo ./dns-switcher.sh
```

The script will:
1. Show current DNS configuration
2. Ask for confirmation to proceed
3. Present a menu of DNS options
4. Create automatic backups
5. Configure the selected DNS servers
6. Restart necessary services
7. Verify the configuration

### Uninstalling/Restoring Original DNS

Download and run the uninstaller:

```bash
wget https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher-uninstall.sh
chmod +x dns-switcher-uninstall.sh
sudo ./dns-switcher-uninstall.sh
```

Or if you already have it:

```bash
sudo ./dns-switcher-uninstall.sh
```

The uninstaller will:
1. Show current DNS configuration
2. List available backups
3. Allow you to restore from any backup or reset to defaults
4. Restart services
5. Optionally clean up backup files

## 🔍 Verification

### Check DNS Configuration

```bash
sudo resolvectl status | grep -E "DNS Servers|DNS Domain"
```

Expected output after installation:
```
         DNS Servers: 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1
Fallback DNS Servers: 9.9.9.9
          DNS Domain: ~.
```

### Monitor DNS Queries in Real-Time

```bash
sudo tcpdump -i any port 53 -n -Q out
```

You should see queries going to your configured DNS servers (e.g., 8.8.8.8).

### Test DNS Resolution

```bash
nslookup google.com
dig google.com
```

## 💻 System Requirements

- Linux system with systemd (Ubuntu 18.04+, Debian 10+, CentOS 8+, etc.)
- systemd-resolved service
- Root/sudo access
- Basic utilities: `wget`, `bash`

## 📁 File Locations

- **Configuration file**: `/etc/systemd/resolved.conf`
- **Backup directory**: `/etc/dns-switcher-backup/`
- **Backup naming**: `resolved.conf.backup.YYYYMMDD_HHMMSS`

## 🔧 Technical Details

The script modifies `/etc/systemd/resolved.conf` with the following settings:

```ini
[Resolve]
DNS=8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1
FallbackDNS=9.9.9.9
Domains=~.
DNSSEC=no
DNSOverTLS=no
Cache=yes
```

### Why Not Modify cloud-init?

Cloud-init configurations are overwritten on system reboot. This script uses systemd-resolved, which persists across reboots and takes precedence over cloud-init network settings.

### Policy-Based Routing (PBR)

If your system has `/opt/setup-pbr.sh`, the script will automatically restart it after DNS configuration to ensure routing tables are updated.

## 🛠️ Troubleshooting

### DNS not changing after script execution

1. Check if systemd-resolved is running:
```bash
systemctl status systemd-resolved
```

2. Verify the configuration:
```bash
cat /etc/systemd/resolved.conf
```

3. Restart the service manually:
```bash
sudo systemctl restart systemd-resolved
```

### DNS not persisting after reboot

1. Ensure systemd-resolved is enabled:
```bash
sudo systemctl enable systemd-resolved
```

2. Check for conflicting network managers:
```bash
systemctl status NetworkManager
```

### Want to use different DNS servers

Simply run the script again and choose option 5 for custom DNS servers.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This script modifies system DNS settings. While it creates backups, always test in a non-production environment first. The authors are not responsible for any issues that may arise from using this script.

## 🌟 Credits

Created for easy DNS switching on Yandex Cloud VMs and other Linux systems.

---

**Made with ❤️ for the Linux community**
