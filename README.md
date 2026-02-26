# Docker Desktop Uninstaller for macOS

A comprehensive, safe, and transparent bash script to completely remove Docker Desktop and all its associated components from macOS.

## Why This Script?
Docker Desktop scatters files across your system—in `/Applications`, `/Library`, `/usr/local/bin`, and `~/Library`. Simply dragging Docker.app to the Trash leaves gigabytes of hidden VMs, configuration files, and helper tools behind. This script hunts them all down and removes them safely.

## Features
* **Complete Cleanup**: Removes the app, VMs, privileged helpers, CLI binaries, plugins, and shell completions.
* **Safe by Default**: Requires confirmation before running and prompts for `sudo` only once upfront.
* **Data Preservation Flag**: Includes an option to keep your containers, images, and volumes intact while reinstalling the app itself.
* **Transparent**: Tells you exactly what it's stopping and removing as it runs.

## Usage

### Complete Removal (Destructive)
WARNING: This will permanently delete Docker Desktop and ALL your containers, images, and volumes.

```bash
git clone https://github.com/Prakharprasun/docker-desktop-uninstaller-macos.git
cd docker-desktop-uninstaller-macos
chmod +x uninstall-docker.sh
./uninstall-docker.sh
```

### Preserve Data (Safe)
Use the `--preserve-data` flag to remove the Docker Desktop app and system binaries but leave your `~/.docker` folder and container VMs intact. This is the recommended option if you are trying to fix a broken Docker installation without losing your work.

```bash
./uninstall-docker.sh --preserve-data
```
