# 📘 DNS Switcher - Usage Examples

This document provides detailed usage examples and common scenarios for the DNS Switcher.

## 🎯 Common Use Cases

### 1. Quick Setup with Default DNS (Google + Cloudflare)

```bash
# Download and run in one command
wget "https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh" -O dns-switcher.sh && chmod +x dns-switcher.sh && sudo bash dns-switcher.sh
```

When prompted:
- Press `y` to proceed
- Press Enter (or type `1`) to use default Google + Cloudflare DNS

### 2. Using Only Google DNS

```bash
sudo ./dns-switcher.sh
```

When prompted:
- Press `y` to proceed
- Type `2` for Google DNS only

### 3. Using Only Cloudflare DNS

```bash
sudo ./dns-switcher.sh
```

When prompted:
- Press `y` to proceed
- Type `3` for Cloudflare DNS only

### 4. Using Custom DNS Servers

```bash
sudo ./dns-switcher.sh
```

When prompted:
- Press `y` to proceed
- Type `5` for custom DNS
- Enter your primary DNS servers: `208.67.222.222 208.67.220.220` (OpenDNS example)
- Enter fallback DNS: `1.1.1.1`

### 5. Verifying Installation on Yandex Cloud VM

After running the script on a Yandex Cloud VM:

```bash
# Check DNS configuration
sudo resolvectl status | grep -E "DNS Servers|DNS Domain"
```

Expected output:
```
         DNS Servers: 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1
Fallback DNS Servers: 9.9.9.9
          DNS Domain: ~.
       DNS Servers: 10.128.0.2
        DNS Domain: ru-central1.internal auto.internal
       DNS Servers: 10.131.0.2
        DNS Domain: ru-central1.internal auto.internal
```

Note: The Yandex Cloud internal DNS servers will still appear but won't be used for external queries.

### 6. Monitoring DNS Queries

```bash
# Monitor all outgoing DNS queries
sudo tcpdump -i any port 53 -n -Q out
```

You should see queries going to 8.8.8.8 (or your configured DNS):
```
20:04:33.281799 eth0  Out IP 10.128.0.26.60205 > 8.8.8.8.53: 59923+ [1au] AAAA? apiok.ru. (37)
20:04:33.358680 eth0  Out IP 10.128.0.26.37721 > 8.8.8.8.53: 21819+ [1au] AAAA? ads.x5.ru. (38)
```

### 7. Testing After Reboot

```bash
# Reboot the system
sudo reboot

# After reboot, verify DNS is still configured
sudo resolvectl status | grep -E "DNS Servers|DNS Domain"

# Test DNS resolution
nslookup google.com
dig cloudflare.com
```

## 🔄 Restoration Examples

### 1. Quick Restore to Previous Configuration

```bash
# Download and run uninstaller
wget https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher-uninstall.sh
chmod +x dns-switcher-uninstall.sh
sudo ./dns-switcher-uninstall.sh
```

When prompted:
- Press `y` to proceed
- Type `1` to restore the most recent backup

### 2. Restore to System Defaults

```bash
sudo ./dns-switcher-uninstall.sh
```

When prompted:
- Press `y` to proceed
- Type `0` to reset to system defaults

### 3. Restore Specific Backup

```bash
sudo ./dns-switcher-uninstall.sh
```

The script will show available backups:
```
📦 Available backups:

1) resolved.conf.backup.20260111_150230 (2026-01-11 15:02:30)
2) resolved.conf.backup.20260111_140115 (2026-01-11 14:01:15)
3) resolved.conf.backup.20260110_120000 (2026-01-10 12:00:00)

0) Reset to system defaults (remove custom DNS)
```

Select the backup you want to restore.

### 4. Restore and Clean Up Backups

```bash
sudo ./dns-switcher-uninstall.sh
```

After restoration, when asked about cleanup:
- Type `y` to remove all backups
- Type `n` to keep backups

## 🚀 Advanced Scenarios

### Yandex Cloud Multi-Interface VM

For VMs with multiple network interfaces:

```bash
# 1. Check current configuration
sudo resolvectl status

# 2. Run DNS switcher
sudo ./dns-switcher.sh

# 3. Verify all interfaces
sudo resolvectl status

# 4. If you have PBR (Policy-Based Routing)
# The script automatically restarts /opt/setup-pbr.sh if present

# 5. Monitor DNS on specific interface
sudo tcpdump -i eth0 port 53 -n -Q out
```

### Automated Deployment

For deploying across multiple servers:

```bash
#!/bin/bash
# deploy-dns.sh

SERVERS=(
    "server1.example.com"
    "server2.example.com"
    "server3.example.com"
)

for server in "${SERVERS[@]}"; do
    echo "Configuring DNS on $server"
    ssh root@$server 'wget -q "https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh" -O /tmp/dns-switcher.sh && \
                      chmod +x /tmp/dns-switcher.sh && \
                      echo -e "y\n1\n" | bash /tmp/dns-switcher.sh'
done
```

### Using with Ansible

```yaml
---
- name: Configure DNS on all servers
  hosts: all
  become: yes
  tasks:
    - name: Download DNS switcher
      get_url:
        url: https://raw.githubusercontent.com/AndreyTimoschuk/dns-switcher/main/dns-switcher.sh
        dest: /tmp/dns-switcher.sh
        mode: '0755'
    
    - name: Run DNS switcher with default settings
      shell: |
        echo -e "y\n1\n" | bash /tmp/dns-switcher.sh
      args:
        creates: /etc/dns-switcher-backup/resolved.conf.backup.*
```

### Testing Different DNS Providers

Compare performance of different DNS providers:

```bash
# Install dnsperf or use dig
sudo apt-get install dnsperf -y

# Test Google DNS
echo "google.com" > /tmp/test-domains.txt
dig @8.8.8.8 google.com | grep "Query time"

# Test Cloudflare DNS
dig @1.1.1.1 google.com | grep "Query time"

# Test Quad9 DNS
dig @9.9.9.9 google.com | grep "Query time"

# Then configure the fastest one
sudo ./dns-switcher.sh
```

## 🔍 Troubleshooting Examples

### DNS Not Changing

```bash
# Check systemd-resolved status
sudo systemctl status systemd-resolved

# If not running, start it
sudo systemctl start systemd-resolved
sudo systemctl enable systemd-resolved

# Check configuration file
cat /etc/systemd/resolved.conf

# Manually restart
sudo systemctl restart systemd-resolved

# Check logs
sudo journalctl -u systemd-resolved -n 50
```

### Conflicts with NetworkManager

```bash
# Check NetworkManager status
systemctl status NetworkManager

# If NetworkManager is managing DNS
sudo nano /etc/NetworkManager/NetworkManager.conf

# Add under [main]:
# dns=none

# Restart NetworkManager
sudo systemctl restart NetworkManager
sudo systemctl restart systemd-resolved
```

### Verify DNS Resolution Path

```bash
# Check resolution path
resolvectl query google.com

# Check DNS statistics
resolvectl statistics

# Flush DNS cache
sudo resolvectl flush-caches

# Test resolution
dig google.com
nslookup google.com
host google.com
```

## 📊 Performance Monitoring

### Monitor DNS Response Times

```bash
# Install dnsdiag
pip3 install dnsdiag

# Test current DNS
dnsping -c 10 -s 8.8.8.8 google.com

# Compare providers
echo "Testing Google DNS:"
dnsping -c 5 -s 8.8.8.8 google.com
echo "Testing Cloudflare DNS:"
dnsping -c 5 -s 1.1.1.1 google.com
echo "Testing Quad9 DNS:"
dnsping -c 5 -s 9.9.9.9 google.com
```

### Check DNS Cache

```bash
# View cache statistics
sudo resolvectl statistics

# Flush cache
sudo resolvectl flush-caches

# Monitor cache hits
watch -n 1 'sudo resolvectl statistics'
```

## 🎓 Educational Examples

### Understanding the Changes

```bash
# Before running script
echo "=== BEFORE ==="
sudo resolvectl status | grep -E "DNS Servers|DNS Domain"

# Run the script
sudo ./dns-switcher.sh

# After running script
echo "=== AFTER ==="
sudo resolvectl status | grep -E "DNS Servers|DNS Domain"

# Check configuration file changes
echo "=== CONFIG FILE ==="
cat /etc/systemd/resolved.conf

# Check backup
echo "=== BACKUP ==="
ls -lh /etc/dns-switcher-backup/
```

### Manual Configuration (Educational)

If you want to understand what the script does:

```bash
# 1. Backup current config
sudo cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.backup

# 2. Edit configuration
sudo nano /etc/systemd/resolved.conf

# Add under [Resolve]:
# DNS=8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1
# FallbackDNS=9.9.9.9
# Domains=~.
# DNSSEC=no
# DNSOverTLS=no

# 3. Restart service
sudo systemctl restart systemd-resolved

# 4. Verify
sudo resolvectl status
```

---

## 🌟 Tips and Best Practices

1. **Always verify** DNS changes with `resolvectl status`
2. **Test after reboot** to ensure persistence
3. **Keep backups** for easy rollback
4. **Monitor queries** with tcpdump when troubleshooting
5. **Compare performance** before choosing a provider
6. **Use automation** for multiple servers

## 📞 Need Help?

If none of these examples solve your issue, please:
- Check the main [README.md](README.md)
- Open an issue on GitHub
- Review systemd-resolved documentation
