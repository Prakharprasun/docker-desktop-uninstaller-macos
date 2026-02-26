# Docker Desktop Uninstaller for macOS

A comprehensive, safe, and transparent bash script to completely remove Docker Desktop and all its associated components from macOS.

## Why This Script?

Docker Desktop scatters files across your system—in `/Applications`, `/Library`, `/usr/local/bin`, and `~/Library`. Simply dragging Docker.app to the Trash leaves gigabytes of hidden VMs, configuration files, and helper tools behind. This script hunts them all down and removes them safely.

## Use Cases

* Fix broken Docker Desktop installs
* Resolve "Cannot connect to Docker daemon" recurring issues
* Clean reinstall Docker from scratch
* Remove Docker completely to free up disk space
* Fix Homebrew Docker install conflicts
* Clear out bloated 50GB+ hidden VM data files

## Features

* **Complete Cleanup**: Removes the app, VMs, privileged helpers, CLI binaries, plugins, and shell completions.
* **Safe by Default**: Requires confirmation before running and prompts for `sudo` only once upfront.
* **Preview Mode**: Includes a `--dry-run` flag to print exactly what would be removed without deleting anything.
* **Data Preservation Flag**: Includes an option to keep your containers, images, and volumes intact while reinstalling the app itself.
* **Transparent**: Tells you exactly what it's stopping and removing as it runs.

## Usage

### Option 1: Quick Run via Curl (Recommended)

**Complete Removal (Destructive):**
WARNING: This will permanently delete Docker Desktop and ALL your containers, images, and volumes.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Prakharprasun/docker-desktop-uninstaller-macos/main/uninstall-docker.sh)"
```

**Preserve Data (Safe):**
Use the `--preserve-data` flag to remove the Docker Desktop app and system binaries but leave your `~/.docker` folder and container VMs intact.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Prakharprasun/docker-desktop-uninstaller-macos/main/uninstall-docker.sh)" -- --preserve-data
```

**Dry Run (Preview Mode):**
Use the `--dry-run` flag to see exactly what files and folders would be deleted across your entire system, without actually deleting anything.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Prakharprasun/docker-desktop-uninstaller-macos/main/uninstall-docker.sh)" -- --dry-run
```

### Option 2: Clone and Run

**Complete Removal (Destructive):**

```bash
git clone https://github.com/Prakharprasun/docker-desktop-uninstaller-macos.git
cd docker-desktop-uninstaller-macos
chmod +x uninstall-docker.sh
./uninstall-docker.sh
```

**Preserve Data (Safe):**

```bash
./uninstall-docker.sh --preserve-data
```

**Dry Run (Preview Mode):**

```bash
./uninstall-docker.sh --dry-run
```
