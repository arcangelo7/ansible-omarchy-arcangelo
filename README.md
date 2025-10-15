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
    └── system_settings/     # System settings (monitor, keyboard)
        ├── tasks/
        │   └── main.yml
        ├── templates/
        │   └── monitors.conf.j2
        ├── handlers/
        │   └── main.yml
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

Removes unwanted software from the system.

**Packages removed:**
- 1password-beta (including config files)
- 1password-cli (including config files)
- signal-desktop (including config files)
- typora (including config files)

**Web apps removed:**
- Basecamp (including desktop entry, icons, config and cache files)
- Google Contacts (including desktop entry, icons, config and cache files)
- Google Messages (including desktop entry, icons, config and cache files)
- Google Photos (including desktop entry, icons, config and cache files)
- HEY (including desktop entry, icons, config and cache files)
- ChatGPT (including desktop entry, icons, config and cache files)

**Keybindings removed:**
- Super + A: ChatGPT
- Super + Shift + A: Grok
- Super + C: HEY Calendar
- Super + E: HEY Email

**Keybinding updates:**
- Super + G: Now opens WhatsApp (previously Signal)
- Super + Shift + G: Removed (previously WhatsApp)

### 2. applications_install

Installs essential applications and web apps.

**Packages installed:**
- bitwarden (desktop app)

**Web apps installed:**
- Claude (AI assistant by Anthropic)
  - URL: https://claude.ai
  - Keybinding: Super + A

### 3. hyprland_config

Manages Hyprland configuration files.

**Features:**
- Updates password manager keybinding (SUPER + /) to use bitwarden
- Creates backup of bindings.conf before modifications
- Automatically reloads Hyprland configuration

### 4. system_settings

Configures system-level settings for Omarchy (monitor scaling, keyboard layout).

**Features:**
- Automatic monitor scaling configuration based on display type
- US International keyboard layout with dead keys
- Backup of configurations before changes
- Automatic Hyprland reload after changes

**Configuration:**
Edit `group_vars/all/system_settings.yml` to customize:
- Monitor scaling (GDK_SCALE and Hyprland scale)
- Monitor resolution and refresh rate

**Current setup:**
- Monitor: Ultrawide (3440x1440@100Hz)
- Scaling: 1x (optimized for ~109 PPI displays)
- Keyboard: US International with dead keys

## Omarchy compliance

This configuration:
- Does not remove critical packages (Hyprland, Neovim, Alacritty, Chromium)
- Does not modify essential keybindings
- Does not touch critical Omarchy configurations