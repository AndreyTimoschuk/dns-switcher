# 🤝 Contributing to DNS Switcher

Thank you for considering contributing to DNS Switcher! This document outlines the process and guidelines for contributing.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Commit Messages](#commit-messages)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## 📜 Code of Conduct

This project follows a simple code of conduct:
- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## 🚀 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **System information** (OS, version, etc.)
- **Logs or error messages**

Example:
```markdown
**Title:** DNS not persisting after reboot on Ubuntu 22.04

**Description:**
After running the script, DNS changes work initially but revert after reboot.

**Steps to Reproduce:**
1. Run `sudo ./dns-switcher.sh`
2. Select option 1 (Google + Cloudflare)
3. Reboot system
4. Check DNS with `resolvectl status`

**Expected:** DNS should remain as configured
**Actual:** DNS reverts to default

**System Info:**
- OS: Ubuntu 22.04 LTS
- systemd version: 249
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- **Clear use case**
- **Proposed solution**
- **Alternative solutions considered**
- **Impact on existing functionality**

### Adding DNS Providers

To add a new DNS provider:

1. Add the provider to the menu in `dns-switcher.sh`
2. Include DNS server addresses
3. Add documentation in README.md
4. Include usage example in USAGE_EXAMPLES.md

Example:
```bash
echo "6) AdGuard DNS"
echo "   Primary: 94.140.14.14, 94.140.15.15"
echo "   Fallback: 1.1.1.1"
```

### Improving Documentation

Documentation improvements are always welcome:
- Fix typos or clarify existing docs
- Add more examples
- Translate to other languages
- Add diagrams or screenshots

## 💻 Development Setup

### Prerequisites

- Linux system with systemd
- Bash 4.0+
- Git
- Text editor

### Getting Started

1. Fork the repository
2. Clone your fork:
```bash
git clone https://github.com/AndreyTimoschuk/dns-switcher.git
cd dns-switcher
```

3. Create a branch:
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

4. Make your changes

5. Test your changes (see Testing section)

## 📝 Coding Guidelines

### Shell Script Style

Follow these guidelines for shell scripts:

1. **Use ShellCheck**: Validate scripts with shellcheck
```bash
shellcheck dns-switcher.sh
shellcheck dns-switcher-uninstall.sh
```

2. **Indentation**: Use 4 spaces (no tabs)

3. **Variables**: 
   - Use UPPERCASE for globals/constants
   - Use lowercase for local variables
   ```bash
   # Good
   DEFAULT_DNS="8.8.8.8"
   local user_choice
   
   # Bad
   defaultDns="8.8.8.8"
   LOCAL_VAR="value"
   ```

4. **Functions**:
   - Use descriptive names with underscores
   - Add comments explaining purpose
   ```bash
   # Check if running as root
   check_root() {
       if [[ $EUID -ne 0 ]]; then
           print_message "$RED" "Must run as root"
           exit 1
       fi
   }
   ```

5. **Error Handling**:
   - Always check command success
   - Use `set -e` for critical scripts
   - Provide meaningful error messages

6. **Comments**:
   - Use comments for complex logic
   - Don't state the obvious
   ```bash
   # Good: Explain why
   # Restart PBR to update routing tables with new DNS
   restart_pbr
   
   # Bad: State the obvious
   # Call restart_pbr function
   restart_pbr
   ```

### Color Codes

Use existing color variables:
- `$RED` - Errors
- `$GREEN` - Success
- `$YELLOW` - Warnings
- `$BLUE` - Information
- `$NC` - Reset color

### Output Messages

Use `print_message` function:
```bash
print_message "$GREEN" "✓ Success message"
print_message "$RED" "❌ Error message"
print_message "$YELLOW" "⚠️  Warning message"
print_message "$BLUE" "ℹ️  Information"
```

## 📨 Commit Messages

Follow these commit message guidelines:

### Format
```
<type>: <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

Good:
```
feat: Add AdGuard DNS option

- Add AdGuard DNS to provider menu
- Update documentation with AdGuard info
- Add usage example

Closes #42
```

```
fix: DNS not persisting after reboot

- Ensure systemd-resolved is enabled
- Add verification step after configuration
- Improve error messages

Fixes #15
```

Bad:
```
update stuff
```

```
Fixed bug
```

## 🧪 Testing

### Manual Testing Checklist

Before submitting a PR, test the following:

#### Installation
- [ ] Script downloads correctly
- [ ] Permissions are set correctly
- [ ] Script runs without syntax errors

#### DNS Configuration
- [ ] All DNS provider options work
- [ ] Custom DNS option works
- [ ] DNS changes are applied correctly
- [ ] Changes persist after reboot

#### Backup and Restore
- [ ] Backups are created
- [ ] Uninstaller lists backups correctly
- [ ] Restore from backup works
- [ ] Reset to defaults works

#### Error Handling
- [ ] Non-root execution shows error
- [ ] Invalid input handled gracefully
- [ ] Missing dependencies detected

#### Compatibility
- [ ] Works on Ubuntu 20.04+
- [ ] Works on Debian 10+
- [ ] Works on CentOS 8+
- [ ] Works on Yandex Cloud VMs

### Testing on VM

Create a test VM:
```bash
# Use Vagrant or your preferred VM tool
vagrant init ubuntu/focal64
vagrant up
vagrant ssh

# Test the script
wget YOUR_SCRIPT_URL
chmod +x dns-switcher.sh
sudo ./dns-switcher.sh
```

### Testing Script

Create a simple test script:
```bash
#!/bin/bash
# test-dns-switcher.sh

echo "Testing DNS Switcher..."

# Test 1: Check script syntax
echo "1. Checking syntax..."
bash -n dns-switcher.sh && echo "✓ Syntax OK" || echo "✗ Syntax error"

# Test 2: Check shellcheck
echo "2. Running shellcheck..."
shellcheck dns-switcher.sh && echo "✓ ShellCheck passed" || echo "✗ ShellCheck failed"

# Test 3: Check executability
echo "3. Checking permissions..."
[ -x dns-switcher.sh ] && echo "✓ Executable" || echo "✗ Not executable"

# Add more tests as needed
```

## 🔄 Pull Request Process

1. **Update documentation** if needed
2. **Test your changes** thoroughly
3. **Run shellcheck** on modified scripts
4. **Update CHANGELOG** if applicable
5. **Create pull request** with clear description

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Testing
- [ ] Tested on Ubuntu
- [ ] Tested on Debian
- [ ] Tested on CentOS
- [ ] Tested uninstaller
- [ ] Verified persistence after reboot

## Checklist
- [ ] Code follows style guidelines
- [ ] shellcheck passes
- [ ] Documentation updated
- [ ] Commits follow guidelines

## Screenshots (if applicable)
```

### Review Process

1. Maintainer reviews code
2. Automated checks run (if configured)
3. Discussion and feedback
4. Approval and merge

## 🏷️ Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## ❓ Questions?

- Open an issue for questions
- Check existing issues and PRs
- Review documentation first

## 🙏 Thank You!

Your contributions make this project better for everyone. Thank you for taking the time to contribute!

---

**Happy Contributing! 🚀**
