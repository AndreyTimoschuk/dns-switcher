#!/bin/bash

# DNS Switcher Uninstaller
# Restores original DNS configuration
# Author: Your Name
# License: MIT

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    print_message "$BLUE" "║    DNS Switcher - Uninstaller          ║"
    print_message "$BLUE" "║   Restore Original DNS Settings        ║"
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

# Show current DNS settings
show_current_dns() {
    print_message "$BLUE" "📋 Current DNS configuration:"
    echo ""
    resolvectl status | grep -E "DNS Servers|DNS Domain|Fallback DNS" || true
    echo ""
}

# List available backups
list_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_message "$RED" "❌ No backups found in $BACKUP_DIR"
        exit 1
    fi
    
    local backup_files=($(ls -t "$BACKUP_DIR"/resolved.conf.backup.* 2>/dev/null || true))
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        print_message "$RED" "❌ No backup files found"
        exit 1
    fi
    
    print_message "$BLUE" "📦 Available backups:"
    echo ""
    
    local i=1
    for backup in "${backup_files[@]}"; do
        local backup_name=$(basename "$backup")
        local backup_date=$(echo "$backup_name" | grep -oP '\d{8}_\d{6}' || echo "unknown")
        echo "$i) $backup_name ($(date -d "${backup_date:0:8} ${backup_date:9:2}:${backup_date:11:2}:${backup_date:13:2}" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "$backup_date"))"
        ((i++))
    done
    
    echo ""
    echo "0) Reset to system defaults (remove custom DNS)"
    echo ""
    
    BACKUP_FILES=("${backup_files[@]}")
}

# Restore from backup
restore_backup() {
    local choice=$1
    
    if [[ "$choice" == "0" ]]; then
        print_message "$BLUE" "🔄 Resetting to system defaults..."
        
        # Create minimal resolved.conf
        cat > /etc/systemd/resolved.conf <<EOF
# Restored to system defaults by DNS Switcher Uninstaller
# $(date)

[Resolve]
#DNS=
#FallbackDNS=
#Domains=
#DNSSEC=allow-downgrade
#DNSOverTLS=no
EOF
        
        print_message "$GREEN" "✓ Reset to system defaults"
    else
        local backup_index=$((choice - 1))
        
        if [[ $backup_index -lt 0 || $backup_index -ge ${#BACKUP_FILES[@]} ]]; then
            print_message "$RED" "❌ Invalid choice"
            exit 1
        fi
        
        local backup_file="${BACKUP_FILES[$backup_index]}"
        
        print_message "$BLUE" "🔄 Restoring from backup: $(basename "$backup_file")"
        
        cp "$backup_file" /etc/systemd/resolved.conf
        
        print_message "$GREEN" "✓ Restored from backup"
    fi
    
    echo ""
}

# Restart services
restart_services() {
    print_message "$BLUE" "🔄 Restarting systemd-resolved..."
    systemctl restart systemd-resolved
    
    sleep 2
    
    print_message "$GREEN" "✓ systemd-resolved restarted"
    echo ""
    
    # Restart PBR if exists
    if [[ -f /opt/setup-pbr.sh ]]; then
        print_message "$BLUE" "🔄 Restarting Policy-Based Routing..."
        /opt/setup-pbr.sh
        print_message "$GREEN" "✓ PBR restarted"
        echo ""
    fi
}

# Verify DNS configuration
verify_dns() {
    print_message "$BLUE" "✅ Current DNS configuration:"
    echo ""
    
    resolvectl status | grep -E "DNS Servers|DNS Domain|Fallback DNS" || true
    
    echo ""
}

# Cleanup option
cleanup_backups() {
    read -p "Do you want to remove all backups from $BACKUP_DIR? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$BACKUP_DIR"
        print_message "$GREEN" "✓ Backups removed"
    else
        print_message "$YELLOW" "Backups preserved in $BACKUP_DIR"
    fi
    
    echo ""
}

# Main function
main() {
    print_header
    check_root
    
    show_current_dns
    
    read -p "Do you want to restore original DNS settings? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_message "$YELLOW" "Operation cancelled."
        exit 0
    fi
    
    echo ""
    
    list_backups
    
    read -p "Select backup to restore (0-${#BACKUP_FILES[@]}): " choice
    
    restore_backup "$choice"
    remove_persistent_service
    restart_services
    verify_dns
    
    print_message "$GREEN" "╔════════════════════════════════════════╗"
    print_message "$GREEN" "║   DNS Restoration Complete! ✓          ║"
    print_message "$GREEN" "╚════════════════════════════════════════╝"
    echo ""
    
    cleanup_backups
    
    print_message "$YELLOW" "💡 To verify after reboot, run:"
    echo ""
    echo "  sudo resolvectl status | grep -E \"DNS Servers|DNS Domain\""
    echo ""
}

# Run main function
main
