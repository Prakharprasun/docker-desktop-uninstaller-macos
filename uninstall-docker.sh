#!/usr/bin/env bash
set -e

# Default to removing everything
PRESERVE_DATA=false

# Parse flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --preserve-data) PRESERVE_DATA=true ;;
        -h|--help)
            echo "Usage: ./uninstall-docker.sh [OPTIONS]"
            echo "Completely uninstalls Docker Desktop for Mac."
            echo ""
            echo "Options:"
            echo "  --preserve-data    Keep ~/.docker and container data to prevent data loss."
            echo "  -h, --help         Show this help message."
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "⚠️  WARNING: This script will permanently remove Docker Desktop from your Mac."
if [ "$PRESERVE_DATA" = false ]; then
    echo "This includes ALL containers, images, and volumes!"
fi
echo ""
read -p "Continue? (y/N): " confirm
[[ "$confirm" == "y" || "$confirm" == "Y" ]] || { echo "Aborted."; exit 0; }

echo ""
echo "Requesting administrator privileges..."
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Stopping Docker processes..."
pkill -f Docker 2>/dev/null || true
osascript -e 'quit app "Docker"' 2>/dev/null || true

echo "Removing Docker Desktop app..."
sudo rm -rf /Applications/Docker.app

echo "Removing privileged helpers..."
sudo rm -f /Library/PrivilegedHelperTools/com.docker.vmnetd
sudo rm -f /Library/LaunchDaemons/com.docker.vmnetd.plist

echo "Removing CLI binaries..."
sudo rm -f /usr/local/bin/docker
sudo rm -f /usr/local/bin/docker-credential-desktop
sudo rm -f /usr/local/bin/docker-credential-ecr-login
sudo rm -f /usr/local/bin/docker-credential-osxkeychain
sudo rm -f /usr/local/bin/kubectl.docker
sudo rm -f /usr/local/bin/hub-tool
sudo rm -f /usr/local/bin/docker-compose
sudo rm -f /usr/local/bin/docker-buildx
sudo rm -f /usr/local/bin/docker-extension
sudo rm -f /usr/local/bin/docker-sbom
sudo rm -f /usr/local/bin/docker-scan

echo "Removing CLI plugins..."
sudo rm -rf /usr/local/cli-plugins
sudo rm -rf ~/.docker/cli-plugins

echo "Removing shell completions..."
sudo rm -f /opt/homebrew/etc/bash_completion.d/docker*
sudo rm -f /opt/homebrew/share/zsh/site-functions/_docker*
sudo rm -f /opt/homebrew/share/fish/vendor_completions.d/docker*

if [ "$PRESERVE_DATA" = false ]; then
    echo "Removing user data..."
    rm -rf ~/.docker
    rm -rf ~/Library/Containers/com.docker.docker
    rm -rf ~/Library/Application\ Support/Docker\ Desktop
    rm -rf ~/Library/Group\ Containers/group.com.docker
    rm -rf ~/Library/Cookies/com.docker.docker.binarycookies
    rm -rf ~/Library/Logs/Docker\ Desktop
    rm -rf ~/Library/Preferences/com.docker.docker.plist
    rm -rf ~/Library/Preferences/com.electron.docker-frontend.plist
    rm -rf ~/Library/Saved\ Application\ State/com.electron.docker-frontend.savedState
else
    echo "Keeping user data (--preserve-data flag used)."
fi

echo "Removing Homebrew cask remnants..."
rm -rf /opt/homebrew/Caskroom/docker 2>/dev/null || true
rm -rf ~/Library/Caches/Homebrew/downloads/*Docker* 2>/dev/null || true

echo ""
echo "✅ Docker Desktop completely removed."
