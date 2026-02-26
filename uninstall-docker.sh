#!/usr/bin/env bash
set -e

# Default to removing everything
PRESERVE_DATA=false
DRY_RUN=false

# Detect Homebrew prefix automatically
if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX="$(brew --prefix)"
else
    BREW_PREFIX="/usr/local"
fi

# Parse flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --preserve-data) PRESERVE_DATA=true ;;
        --dry-run) DRY_RUN=true ;;
        -h|--help)
            echo "Usage: ./uninstall-docker.sh [OPTIONS]"
            echo "Completely uninstalls Docker Desktop for Mac."
            echo ""
            echo "Options:"
            echo "  --preserve-data    Keep ~/.docker and container data to prevent data loss."
            echo "  --dry-run          Print what would be removed without actually deleting it."
            echo "  -h, --help         Show this help message."
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ "$DRY_RUN" = true ]; then
    echo "Mode: DRY RUN (No files will be deleted)"
    echo ""
    confirm="y"
else
    echo "⚠️  WARNING: This script will permanently remove Docker Desktop from your Mac."
    if [ "$PRESERVE_DATA" = false ]; then
        echo "This includes ALL containers, images, and volumes!"
    fi
    echo ""
    read -p "Continue? (y/N): " confirm
fi

[[ "$confirm" == "y" || "$confirm" == "Y" ]] || { echo "Aborted."; exit 0; }

if [ "$DRY_RUN" = false ]; then
    echo ""
    echo "Requesting administrator privileges..."
    sudo -v
    # Keep-alive: update existing `sudo` time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# Helper function to remove a file or directory safely
remove_item() {
    local target="$1"
    local is_privileged="${2:-false}"

    if compgen -G "$target" > /dev/null || [ -e "$target" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "Would remove: $target"
        else
            if [ "$is_privileged" = true ]; then
                sudo rm -rf "$target"
            else
                rm -rf "$target"
            fi
        fi
    fi
}

echo "Stopping Docker processes..."
if [ "$DRY_RUN" = false ]; then
    pkill -f Docker 2>/dev/null || true
    pkill -f com.docker.backend 2>/dev/null || true
    pkill -f com.docker.hyperkit 2>/dev/null || true
    pkill -f com.docker.virtualization 2>/dev/null || true
    pkill -f vpnkit 2>/dev/null || true
    pkill -f docker.sock 2>/dev/null || true
    osascript -e 'quit app "Docker"' 2>/dev/null || true
fi

echo "Removing Docker Desktop app..."
remove_item "/Applications/Docker.app" true

echo "Removing privileged helpers..."
if [ "$DRY_RUN" = false ]; then
    sudo launchctl bootout system /Library/LaunchDaemons/com.docker.vmnetd.plist 2>/dev/null || true
    launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/com.docker.helper.plist" 2>/dev/null || true
    launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/com.docker.docker.plist" 2>/dev/null || true
fi
remove_item "/Library/PrivilegedHelperTools/com.docker.vmnetd" true
remove_item "/Library/LaunchDaemons/com.docker.vmnetd.plist" true
remove_item "/Library/Preferences/com.docker.vmnetd.plist" true
remove_item "/Library/Logs/com.docker.vmnetd.log" true
remove_item "/private/var/db/receipts/com.docker.vmnetd.bom" true
remove_item "/private/var/db/receipts/com.docker.vmnetd.plist" true
remove_item "$HOME/Library/LaunchAgents/com.docker.helper.plist"
remove_item "$HOME/Library/LaunchAgents/com.docker.docker.plist"

echo "Removing CLI binaries..."
remove_item "$BREW_PREFIX/bin/docker*" true
remove_item "/usr/local/bin/docker*" true
remove_item "/Applications/Docker.app/Contents/Resources/bin/docker*" true
remove_item "/Applications/Docker.app/Contents/Resources/cli-plugins" true
remove_item "/usr/local/bin/docker-credential-desktop" true
remove_item "/usr/local/bin/docker-credential-ecr-login" true
remove_item "/usr/local/bin/docker-credential-osxkeychain" true
remove_item "/usr/local/bin/kubectl.docker" true
remove_item "/usr/local/bin/hub-tool" true
remove_item "/usr/local/bin/docker-compose" true
remove_item "/usr/local/bin/docker-buildx" true
remove_item "/usr/local/bin/docker-extension" true
remove_item "/usr/local/bin/docker-sbom" true
remove_item "/usr/local/bin/docker-scan" true

echo "Removing CLI plugins..."
remove_item "/usr/local/cli-plugins" true
remove_item "$HOME/.docker/cli-plugins"

echo "Removing shell completions..."
remove_item "$BREW_PREFIX/etc/bash_completion.d/docker*" true
remove_item "$BREW_PREFIX/share/zsh/site-functions/_docker*" true
remove_item "$BREW_PREFIX/share/fish/vendor_completions.d/docker*" true

if [ "$PRESERVE_DATA" = false ]; then
    echo "Removing user data..."
    remove_item "$HOME/.docker"
    remove_item "$HOME/.docker/run"
    remove_item "$HOME/Library/Containers/com.docker.docker"
    remove_item "$HOME/Library/Containers/com.docker.docker/Data/vms"
    remove_item "$HOME/Library/Containers/com.docker.docker/Data/docker.raw"
    remove_item "$HOME/Library/Application Support/Docker Desktop"
    remove_item "$HOME/Library/Group Containers/group.com.docker"
    remove_item "$HOME/Library/Cookies/com.docker.docker.binarycookies"
    remove_item "$HOME/Library/Logs/Docker Desktop"
    remove_item "$HOME/Library/Logs/com.docker.docker"
    remove_item "$HOME/Library/Preferences/com.docker.docker.plist"
    remove_item "$HOME/Library/Preferences/com.electron.docker-frontend.plist"
    remove_item "$HOME/Library/Saved Application State/com.electron.docker-frontend.savedState"
    remove_item "/var/run/docker.sock" true
    remove_item "/var/run/com.docker.vmnetd.sock" true
else
    echo "Keeping user data (--preserve-data flag used)."
fi

echo "Removing System Extensions..."
remove_item "/Library/SystemExtensions/*docker*" true
remove_item "$HOME/Library/SystemExtensions/*docker*"

echo "Removing Homebrew cask remnants..."
remove_item "$BREW_PREFIX/Caskroom/docker"
remove_item "$BREW_PREFIX/Caskroom/docker-desktop"
remove_item "$HOME/Library/Caches/Homebrew/downloads/*docker*"
remove_item "$HOME/Library/Caches/Homebrew/downloads/*Docker*"

echo ""
echo "Verification:"
if command -v docker >/dev/null 2>&1; then
    echo "⚠️  docker binary still exists at: $(command -v docker)"
else
    echo "✅ docker binary not found"
fi

if [ -S /var/run/docker.sock ]; then
    echo "⚠️  docker socket still exists"
else
    echo "✅ docker socket removed"
fi

echo ""
if [ "$DRY_RUN" = true ]; then
    echo "✅ Dry run complete. No files were harmed."
else
    echo "✅ Docker Desktop completely removed."
    
    echo ""
    read -p "Do you want to install a fresh copy of Docker Desktop now? (y/N): " reinstall
    if [[ "$reinstall" == "y" || "$reinstall" == "Y" ]]; then
        if command -v brew >/dev/null 2>&1; then
            echo "Installing Docker Desktop via Homebrew..."
            brew install --cask docker
            echo "Launch Docker from Applications after install."
        else
            echo "Homebrew not found. Install Docker manually from:"
            echo "https://www.docker.com/products/docker-desktop/"
        fi
    fi
fi

exit 0
