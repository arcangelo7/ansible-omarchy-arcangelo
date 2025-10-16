# Ansible Omarchy configuration

Modular Ansible configuration to manage Omarchy installation and configuration on Arch Linux with my personal preferences.

## Structure

```
ansible-omarchy-arcangelo/
├── ansible.cfg              # Ansible configuration
├── inventory.yml            # Inventory (localhost)
├── playbook.yml            # Main playbook
├── CLAUDE.md               # Omarchy automation reference
├── group_vars/
│   └── all/
│       └── system_settings.yml  # System settings variables
└── roles/
    ├── bloatware_removal/   # Unwanted software removal
    │   ├── tasks/
    │   │   └── main.yml
    │   └── vars/
    │       └── main.yml
    ├── applications_install/ # Applications installation
    │   ├── tasks/
    │   │   └── main.yml
    │   └── vars/
    │       └── main.yml
    ├── hyprland_config/     # Hyprland configuration management
    │   ├── tasks/
    │   │   └── main.yml
    │   └── vars/
    │       └── main.yml
    ├── system_settings/     # System settings (monitor, keyboard)
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── templates/
    │   │   └── monitors.conf.j2
    │   ├── handlers/
    │   │   └── main.yml
    │   └── defaults/
    │       └── main.yml
    └── applications_config/ # Applications configuration management
        ├── tasks/
        │   └── main.yml
        ├── templates/
        │   └── alacritty.toml.j2
        └── defaults/
            └── main.yml
```

## Prerequisite

Install Ansible if not already present:
   ```bash
   sudo pacman -S ansible
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

**Packages installed:**
- bitwarden (desktop app)
- gst-plugin-gtk (dependency of Whispering)
- gst-plugins-base (dependency of Whispering)
- gst-plugins-good (dependency of Whispering)
- gst-plugins-bad (dependency of Whispering)
- gst-plugin-pipewire (dependency of Whispering)
- ydotool (keyboard automation tool for Wayland)

**AUR packages installed:**
- whispering-bin (Speech-to-text transcription application with keyboard shortcuts)

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

## Omarchy compliance

This configuration:
- Does not remove critical packages (Hyprland, Neovim, Alacritty, Chromium)
- Does not modify essential keybindings
- Does not touch critical Omarchy configurations