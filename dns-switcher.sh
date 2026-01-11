#!/bin/bash

# DNS Switcher for Linux Systems
# Switches from Yandex Cloud DNS to Google DNS & Cloudflare DNS
# Author: Your Name
# License: MIT

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default DNS servers
DEFAULT_DNS="8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1"
DEFAULT_FALLBACK="9.9.9.9"

# Backup directory
BACKUP_DIR="/etc/dns-switcher-backup"

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    echo ""
    print_message "$BLUE" "╔════════════════════════════════════════╗"
    print_message "$BLUE" "║      DNS Switcher for Linux            ║"
    print_message "$BLUE" "║  Switch to Google & Cloudflare DNS     ║"
    print_message "$BLUE" "╚════════════════════════════════════════╝"
    echo ""
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_message "$RED" "❌ This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check system compatibility
check_compatibility() {
    if ! command -v systemctl &> /dev/null; then
        print_message "$RED" "❌ systemd not found. This script requires systemd-resolved."
        exit 1
    fi
    
    if ! systemctl is-active --quiet systemd-resolved; then
        print_message "$YELLOW" "⚠️  systemd-resolved is not running. Starting it..."
        systemctl start systemd-resolved
        systemctl enable systemd-resolved
    fi
}

# Show current DNS settings
show_current_dns() {
    print_message "$BLUE" "📋 Current DNS configuration:"
    echo ""
    resolvectl status | grep -E "DNS Servers|DNS Domain|Fallback DNS" || true
    echo ""
}

# Get DNS servers from user
get_dns_servers() {
    echo ""
    print_message "$YELLOW" "Please choose DNS servers to use:"
    echo ""
    echo "1) Google DNS + Cloudflare DNS (default)"
    echo "   Primary: 8.8.8.8, 8.8.4.4, 1.1.1.1, 1.0.0.1"
    echo "   Fallback: 9.9.9.9 (Quad9)"
    echo ""
    echo "2) Google DNS only"
    echo "   Primary: 8.8.8.8, 8.8.4.4"
    echo "   Fallback: 9.9.9.9"
    echo ""
    echo "3) Cloudflare DNS only"
    echo "   Primary: 1.1.1.1, 1.0.0.1"
    echo "   Fallback: 9.9.9.9"
    echo ""
    echo "4) Quad9 DNS"
    echo "   Primary: 9.9.9.9, 149.112.112.112"
    echo "   Fallback: 1.1.1.1"
    echo ""
    echo "5) Custom DNS servers"
    echo ""
    
    read -p "Enter your choice (1-5) [default: 1]: " choice
    
    case $choice in
        2)
            DNS_SERVERS="8.8.8.8 8.8.4.4"
            FALLBACK_DNS="9.9.9.9"
            print_message "$GREEN" "✓ Selected: Google DNS"
            ;;
        3)
            DNS_SERVERS="1.1.1.1 1.0.0.1"
            FALLBACK_DNS="9.9.9.9"
            print_message "$GREEN" "✓ Selected: Cloudflare DNS"
            ;;
        4)
            DNS_SERVERS="9.9.9.9 149.112.112.112"
            FALLBACK_DNS="1.1.1.1"
            print_message "$GREEN" "✓ Selected: Quad9 DNS"
            ;;
        5)
            read -p "Enter primary DNS servers (space-separated): " DNS_SERVERS
            read -p "Enter fallback DNS server: " FALLBACK_DNS
            
            if [[ -z "$DNS_SERVERS" ]]; then
                print_message "$RED" "❌ Primary DNS servers cannot be empty"
                exit 1
            fi
            
            if [[ -z "$FALLBACK_DNS" ]]; then
                FALLBACK_DNS="9.9.9.9"
            fi
            
            print_message "$GREEN" "✓ Custom DNS servers configured"
            ;;
        1|"")
            DNS_SERVERS="$DEFAULT_DNS"
            FALLBACK_DNS="$DEFAULT_FALLBACK"
            print_message "$GREEN" "✓ Selected: Google DNS + Cloudflare DNS (default)"
            ;;
        *)
            print_message "$RED" "❌ Invalid choice. Using default."
            DNS_SERVERS="$DEFAULT_DNS"
            FALLBACK_DNS="$DEFAULT_FALLBACK"
            ;;
    esac
    
    echo ""
}

# Create backup
create_backup() {
    print_message "$BLUE" "📦 Creating backup..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup resolved.conf
    if [[ -f /etc/systemd/resolved.conf ]]; then
        cp /etc/systemd/resolved.conf "$BACKUP_DIR/resolved.conf.backup.$(date +%Y%m%d_%H%M%S)"
        print_message "$GREEN" "✓ Backed up /etc/systemd/resolved.conf"
    fi
    
    # Save current DNS settings
    resolvectl status > "$BACKUP_DIR/dns_status.backup.$(date +%Y%m%d_%H%M%S)" 2>&1 || true
    
    echo ""
}

# Configure DNS
configure_dns() {
    print_message "$BLUE" "🔧 Configuring DNS servers..."
    
    # Edit /etc/systemd/resolved.conf
    cat > /etc/systemd/resolved.conf <<EOF
# This file is managed by DNS Switcher
# Original configuration backed up to $BACKUP_DIR

[Resolve]
DNS=$DNS_SERVERS
FallbackDNS=$FALLBACK_DNS
Domains=~.
DNSSEC=no
DNSOverTLS=no
EOF
    
    print_message "$GREEN" "✓ Updated /etc/systemd/resolved.conf"
    
    # Restart systemd-resolved
    print_message "$BLUE" "🔄 Restarting systemd-resolved..."
    systemctl restart systemd-resolved
    
    sleep 2
    
    print_message "$GREEN" "✓ systemd-resolved restarted"
    echo ""
    
    # Set DNS on each network interface
    configure_interface_dns
}

# Configure DNS on network interfaces
configure_interface_dns() {
    print_message "$BLUE" "🔧 Configuring DNS on network interfaces..."
    
    # Get all active network interfaces (excluding lo, docker, warp, etc.)
    local interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(eth|ens|enp)' || true)
    
    if [[ -z "$interfaces" ]]; then
        print_message "$YELLOW" "⚠️  No standard network interfaces found (eth*, ens*, enp*)"
        return
    fi
    
    local dns_array=($DNS_SERVERS)
    
    for interface in $interfaces; do
        # Check if interface is up
        if ip link show "$interface" 2>/dev/null | grep -q "state UP"; then
            print_message "$BLUE" "  Setting DNS on $interface..."
            
            # Set DNS servers on the interface
            resolvectl dns "$interface" ${dns_array[@]} 2>/dev/null || \
                print_message "$YELLOW" "    ⚠️  Could not set DNS on $interface"
            
            print_message "$GREEN" "  ✓ DNS configured on $interface"
        fi
    done
    
    echo ""
}

# Restart PBR if exists
restart_pbr() {
    if [[ -f /opt/setup-pbr.sh ]]; then
        print_message "$BLUE" "🔄 Restarting Policy-Based Routing..."
        /opt/setup-pbr.sh
        print_message "$GREEN" "✓ PBR restarted"
        echo ""
    fi
}

# Verify DNS configuration
verify_dns() {
    print_message "$BLUE" "✅ Verifying DNS configuration..."
    echo ""
    
    resolvectl status | grep -E "DNS Servers|DNS Domain|Fallback DNS" || true
    
    echo ""
    print_message "$GREEN" "✓ DNS configuration applied successfully!"
    echo ""
}

# Test DNS resolution
test_dns() {
    print_message "$BLUE" "🧪 Testing DNS resolution..."
    echo ""
    
    if nslookup google.com > /dev/null 2>&1; then
        print_message "$GREEN" "✓ DNS resolution is working"
    else
        print_message "$YELLOW" "⚠️  DNS resolution test inconclusive"
    fi
    
    echo ""
}

# Show DNS query monitoring tip
show_monitoring_tip() {
    print_message "$BLUE" "💡 To monitor DNS queries in real-time, run:"
    echo ""
    echo "  sudo tcpdump -i any port 53 -n -Q out"
    echo ""
    print_message "$BLUE" "💡 To verify after reboot, run:"
    echo ""
    echo "  sudo resolvectl status | grep -E \"DNS Servers|DNS Domain\""
    echo ""
}

# Main function
main() {
    print_header
    check_root
    check_compatibility
    
    show_current_dns
    
    read -p "Do you want to proceed with DNS configuration? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_message "$YELLOW" "Operation cancelled."
        exit 0
    fi
    
    get_dns_servers
    create_backup
    configure_dns
    restart_pbr
    verify_dns
    test_dns
    show_monitoring_tip
    
    print_message "$GREEN" "╔════════════════════════════════════════╗"
    print_message "$GREEN" "║    DNS Configuration Complete! ✓       ║"
    print_message "$GREEN" "╚════════════════════════════════════════╝"
    echo ""
    print_message "$YELLOW" "💾 Backups saved to: $BACKUP_DIR"
    print_message "$YELLOW" "🗑️  To restore original settings, run: ./dns-switcher-uninstall.sh"
    echo ""
}

# Run main function
main
