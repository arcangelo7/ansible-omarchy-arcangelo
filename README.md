# Ansible Omarchy configuration

Modular Ansible configuration to manage Omarchy installation and configuration on Arch Linux with my personal preferences.

## Prerequisites

Install Ansible if not already present:
   ```bash
   sudo pacman -S ansible
   ```

Install the required Ansible collection for AUR package management:
   ```bash
   ansible-galaxy collection install kewlfft.aur
   ```

## Usage

**Note:** All commands require sudo password. Ansible will prompt for it automatically, or you can use the `-K` flag explicitly.

### Run the entire playbook

```bash
ansible-playbook playbook.yml -K
```

### Run only specific roles using tags

**Bloatware removal only:**
```bash
ansible-playbook playbook.yml --tags bloatware -K
```

### Dry-run mode (check without changes)

```bash
ansible-playbook playbook.yml --check -K
```

### Verbose mode (for debugging)

```bash
ansible-playbook playbook.yml -v -K   # verbose
ansible-playbook playbook.yml -vv -K  # more verbose
ansible-playbook playbook.yml -vvv -K # very verbose
```

## Available modules

### 1. bloatware_removal

Removes unwanted software from the system. Only handles package and file removal.

**Packages removed:**
- 1password-beta (including config files and native messaging hosts)
- 1password-cli
- signal-desktop (including config files)
- typora (including config files)

**Web apps removed:**
- Basecamp (desktop entry, icons, config and cache files)
- Google Contacts (desktop entry, icons, config and cache files)
- Google Messages (desktop entry, icons, config and cache files)
- Google Photos (desktop entry, icons, config and cache files)
- HEY (desktop entry, icons, config and cache files)
- ChatGPT (desktop entry, icons, config and cache files)

**Note:** Keybinding cleanup is handled by the `hyprland_config` role

### 2. applications_install

Installs essential applications and web apps. Supports both official repository packages and AUR packages. Only handles package installation and desktop file creation.

**AUR package management:**
- Creates a dedicated `aur_builder` user for secure AUR package installation
- Configures passwordless sudo access for pacman (required by AUR helpers)
- Uses the `kewlfft.aur` Ansible collection with `yay` as the AUR helper
- The `aur_builder` user is created automatically on first run

**Packages installed:**
- p7zip (command-line file archiver with high compression ratio for 7z format)
- bitwarden (desktop app)
- gst-plugin-gtk (dependency of Whispering)
- gst-plugins-base (dependency of Whispering)
- gst-plugins-good (dependency of Whispering)
- gst-plugins-bad (dependency of Whispering)
- gst-plugin-pipewire (dependency of Whispering)
- ydotool (keyboard automation tool for Wayland)

**AUR packages installed:**
- whispering-bin (speech-to-text transcription application with keyboard shortcuts)
- visual-studio-code-bin (no presentations needed)

**Web apps installed:**
- Claude (AI assistant by Anthropic)
  - URL: https://claude.ai
  - Icon: Downloaded from UXWing (512x512 PNG)
  - Desktop file: Created in `~/.local/share/applications/`

**Note:** Keybindings are configured by the `hyprland_config` role

### 3. hyprland_config

Centralized management of all Hyprland configuration changes. This role is responsible for all modifications to Hyprland config files and ensures proper reload.

**Configuration managed:**
- Password manager keybinding (Super + /) → bitwarden-desktop

**Keybindings removed (bloatware cleanup):**
- Super + A: ChatGPT
- Super + Shift + A: Grok
- Super + C: HEY Calendar
- Super + E: HEY Email
- Super + G: Signal
- Super + Alt + G: Google Messages

**Keybindings updated:**
- Super + G: Now opens WhatsApp (previously Super + Shift + G)

**Keybindings added:**
- Super + A: Claude AI assistant
- Super + C: Visual Studio Code
- Super + R: Voice recording (Whispering toggle)

**Whispering voice recording setup:**
- Creates `~/.local/bin/whispering-toggle` script for Wayland compatibility
- Script behavior: focuses Whispering window and sends spacebar to toggle recording

**Features:**
- Creates backup of configuration files before modifications
- Consolidates all Hyprland configuration changes in one place
- Single `hyprctl reload` at the end of all modifications
- Detailed status reporting for each keybinding operation

**Important:** After first run, logout/login is required for whispering-toggle to work

### 4. system_settings

Configures system-level settings for Omarchy (monitor scaling, keyboard layout, shell integration).

**Features:**
- Automatic monitor scaling configuration based on display type
- US International keyboard layout with dead keys
- Mise shell integration for version management (Node.js, Python, etc.)
- Backup of configurations before changes
- Automatic Hyprland reload after changes

**Configuration:**
Edit `group_vars/all/system_settings.yml` to customize:
- Monitor scaling (GDK_SCALE and Hyprland scale)
- Monitor resolution and refresh rate
- Enable/disable Mise shell integration

**Current setup:**
- Monitor: Ultrawide (3440x1440@100Hz)
- Scaling: 1x (optimized for ~109 PPI displays)
- Keyboard: US International with dead keys
- Mise: Enabled (auto-activates in bash shell)

### 5. applications_config

Manages configuration for various applications.

**Current configurations:**

#### Alacritty terminal
- Configurable font size
- Backup of configuration before changes
- Preserves Omarchy theme integration

**Configuration:**
Edit `roles/applications_config/defaults/main.yml` to customize:

```yaml
alacritty_font_size: 12
```

### 6. developer_tools

Installs developer tools for Python, Node.js, and Flutter development. Automatically installs Node.js LTS via Mise if not already present.

**Python tools installed:**
- python-pipx (install and run Python applications in isolated environments)
- python-poetry (Python dependency management and packaging made easy)
- uv (extremely fast Python package installer and resolver written in Rust)

**NPM packages installed:**
- @anthropic-ai/claude-code (Official CLI for Claude AI by Anthropic)

**Flutter SDK:**
- Installs Flutter SDK following official manual installation guide
- Automatically detects and downloads latest stable release via Flutter releases API
- Installation directory: `~/development/flutter`
- Automatically adds Flutter to PATH in `.bashrc`
- Disables Flutter analytics by default
- Supports manual version updates via `flutter upgrade` command
- Prerequisites (curl, git, unzip, xz, zip, mesa) already included in Arch Linux base
- Installs Linux development dependencies (cmake, ninja) for building Flutter desktop apps
- Installs Android development dependencies:
  - JDK 17 (OpenJDK) via pacman
  - Android SDK, build tools, platform tools, and command-line tools via AUR
  - Automatically copies Android SDK to `~/android-sdk` with proper ownership
  - Configures ANDROID_HOME, ANDROID_AVD_HOME, and JAVA_HOME environment variables
  - Accepts Android licenses automatically
  - Installs Android system images for emulators (Android 34 with Google Play)
- Note: Full installation requires approximately 3-4GB of disk space (including Android SDK)

## Complete keybindings reference

### Applications (SUPER + letter)
- **A**: Claude AI assistant
- **B**: Browser (Chromium)
- **C**: Visual Studio Code
- **D**: Docker (lazydocker in terminal)
- **F**: File manager (Nautilus)
- **G**: WhatsApp
- **M**: Music (Spotify)
- **N**: Editor (Neovim)
- **O**: Obsidian
- **R**: Voice recording (Whispering toggle)
- **T**: Activity monitor (btop in terminal)
- **X**: X (Twitter)
- **Y**: YouTube
- **/**: Passwords (Bitwarden)

### Application variants (SUPER + SHIFT + letter)
- **SHIFT + B**: Browser (private mode)
- **SHIFT + X**: X Post (Twitter compose)

### Menus and utilities (SUPER + special keys)
- **Space**: Application launcher (walker)
- **ALT + Space**: Omarchy menu
- **K**: Show key bindings
- **Escape**: Power menu
- **CTRL + E**: Emoji picker

### Window management (SUPER + keys)
- **Return**: Terminal (Alacritty)
- **W**: Close active window
- **V**: Toggle floating window
- **J**: Toggle split direction
- **P**: Pseudo window (dwindle)
- **Arrow keys**: Move focus
- **SHIFT + Arrow keys**: Swap windows
- **1-0**: Switch to workspace 1-10
- **SHIFT + 1-0**: Move window to workspace 1-10
- **TAB**: Next workspace
- **SHIFT + TAB**: Previous workspace
- **CTRL + TAB**: Former workspace
- **-/=**: Resize window horizontally
- **SHIFT + -/=**: Resize window vertically

### Aesthetics (SUPER + modifiers + Space)
- **SHIFT + Space**: Toggle top bar
- **CTRL + Space**: Next background in theme
- **SHIFT + CTRL + Space**: Pick new theme
- **Backspace**: Toggle window transparency

### Notifications (SUPER + comma)
- **,**: Dismiss last notification
- **SHIFT + ,**: Dismiss all notifications
- **CTRL + ,**: Toggle do-not-disturb mode

### Screenshots and recordings
- **Print**: Screenshot of region
- **SHIFT + Print**: Screenshot of window
- **CTRL + Print**: Screenshot of display
- **ALT + Print**: Screen record region
- **ALT + SHIFT + Print**: Screen record region with audio
- **CTRL + ALT + Print**: Screen record display
- **CTRL + ALT + SHIFT + Print**: Screen record display with audio
- **SUPER + Print**: Color picker

### System
- **CTRL + I**: Toggle locking on idle
- **CTRL + N**: Toggle nightlight
- **CTRL + SUPER + S**: Share menu
- **ALT + Tab**: Cycle windows
- **ALT + SHIFT + Tab**: Cycle windows (reverse)

## Omarchy compliance

This configuration:
- Does not remove critical packages (Hyprland, Neovim, Alacritty, Chromium)
- Does not modify essential keybindings
- Does not touch critical Omarchy configurations