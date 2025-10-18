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

**System reboot required:** After running the playbook for the first time, a reboot is required to ensure all kernel modules and system settings are properly loaded.

### Run only specific roles using tags

**Important:** Tags work at role level only. Each tag runs the entire role (all tasks within that role). There are no task-level tags for granular execution.

**Bloatware removal only:**
```bash
ansible-playbook playbook.yml --tags bloatware -K
```

**Applications installation only:**
```bash
ansible-playbook playbook.yml --tags apps -K
```

**Developer tools installation only:**
```bash
ansible-playbook playbook.yml --tags dev -K
```

**BTRFS maintenance configuration only:**
```bash
ansible-playbook playbook.yml --tags btrfs -K
```

**Multiple roles (apps + Hyprland config):**
```bash
ansible-playbook playbook.yml --tags apps,hyprland -K
```

**Skip bloatware removal:**
```bash
ansible-playbook playbook.yml --skip-tags bloatware -K
```

**Skip heavy developer tools:**
```bash
ansible-playbook playbook.yml --skip-tags dev -K
```

## Available modules

### 1. bloatware_removal

Removes unwanted software from the system. Only handles package and file removal.

**Packages removed:**
| Package | Additional cleanup |
|---------|-------------------|
| 1password-beta | Config files, native messaging hosts |
| 1password-cli | - |
| signal-desktop | Config files |
| typora | Config files |

**Web apps removed:**
Basecamp, Google Contacts, Google Messages, Google Photos, HEY, ChatGPT (includes desktop entries, icons, config and cache files)

**Note:** Keybinding cleanup is handled by the `hyprland_config` role

### 2. applications_install

Installs essential applications and web apps. Supports both official repository packages and AUR packages. Only handles package installation and desktop file creation.

**System upgrade:**
- Full system upgrade (`pacman -Syu`) before installing packages
- AUR packages upgrade (`yay -Syu`) after system upgrade
- Update cache refreshed automatically

**AUR package management:**
- Dedicated `aur_builder` user for secure AUR package installation
- Passwordless sudo access for pacman (required by AUR helpers)
- Uses `kewlfft.aur` Ansible collection with `yay` as AUR helper

**Packages installed:**
| Package | Description |
|---------|-------------|
| p7zip | 7z format archiver |
| bitwarden | Password manager |
| gst-plugin-gtk, gst-plugins-base/good/bad, gst-plugin-pipewire | Whispering dependencies |
| ydotool | Keyboard automation for Wayland |
| wireguard-tools | VPN userspace tools |
| openresolv | WireGuard DNS configuration |
| ddcutil | Monitor control via DDC/CI |
| firefox | Web browser |
| thunderbird | Email client |
| btrfs-assistant | BTRFS management GUI |

**AUR packages installed:**
| Package | Description |
|---------|-------------|
| brave-bin | Privacy-focused browser for web apps |
| whispering-bin | Speech-to-text with keyboard shortcuts |
| visual-studio-code-bin | Code editor |
| zotero-bin | Reference manager |
| ddcui | GUI for ddcutil |

**Web apps installed:**
| App | URL | Notes |
|-----|-----|-------|
| Claude | https://claude.ai | AI assistant by Anthropic |
| Homelab | http://192.168.2.103:3000 | Local IP, requires VPN |

**Note:** Keybindings are configured by the `hyprland_config` role

### 3. hyprland_config

Centralized management of all Hyprland configuration changes. Handles all modifications to Hyprland config files and ensures proper reload.

**Features:**
- Manages password manager keybinding (Super + / → bitwarden-desktop)
- Removes bloatware keybindings (ChatGPT, Grok, HEY, Signal, Google Messages)
- Updates existing keybindings (Super + G: WhatsApp)
- Adds new keybindings (Claude, VSCode, Homelab, Whispering voice recording)
- Creates `~/.local/bin/whispering-toggle` script for Wayland compatibility
- Backs up configuration files before modifications
- Single `hyprctl reload` at the end of all modifications

**Important:** After first run, logout/login is required for whispering-toggle to work

**See:** Complete keybindings reference at the end of this document

### 4. btrfs_maintenance

Configures automatic BTRFS filesystem maintenance tasks.

**Features:**
- Monthly scrubbing (integrity verification and automatic error correction)
- Monthly balancing (space optimization, only for blocks with <50% usage)
- Uses systemd timers for reliable scheduling
- Low priority execution (nice 19, idle I/O scheduling)
- Random delay to avoid resource spikes

### 5. system_settings

Configures system-level settings for Omarchy (monitor scaling, keyboard layout, shell integration).

**Features:**
- Automatic monitor scaling configuration based on display type
- US International keyboard layout with dead keys
- Mise shell integration for version management (Node.js, Python, etc.)
- Backup of configurations before changes
- Automatic Hyprland reload after changes

**Configuration:**
Edit `group_vars/all/system_settings.yml` to customize monitor scaling, resolution, refresh rate, and Mise integration.

**Current setup:**
- Monitor: Ultrawide (3440x1440@100Hz)
- Scaling: 1x (optimized for ~109 PPI displays)
- Keyboard: US International with dead keys
- Mise: Enabled (auto-activates in bash shell)

### 6. applications_config

Manages configuration for various applications.

**Alacritty terminal:**
- Configurable font size
- Preserves Omarchy theme integration

**Default browser:**
- Sets default browser for HTTP/HTTPS links via MIME type associations
- **Firefox**: Default for links from native apps (Thunderbird, terminal, PDF viewer)
- **Brave**: Used automatically for web apps (Claude, Homelab, etc.)
- Modified `omarchy-launch-webapp` script to use Brave instead of Chromium

**Default text editor:**
- Sets Visual Studio Code as default for text files
- Configured MIME types: plain text, markdown, Python, YAML, JSON, shell scripts, C/C++, Java, CSS, JavaScript, XML, log files

**Configuration:**
Edit `roles/applications_config/defaults/main.yml`:
```yaml
alacritty_font_size: 12
default_browser: "firefox.desktop"
default_text_editor: "code.desktop"
```

### 7. developer_tools

Installs developer tools for Python, Node.js, and Flutter development. Automatically installs Node.js LTS via Mise if not already present.

**Python tools:**
| Package | Description |
|---------|-------------|
| python-pipx | Install Python apps in isolated environments |
| python-poetry | Dependency management and packaging |
| uv | Fast Python package installer (Rust) |

**NPM packages:**
- @anthropic-ai/claude-code (Official CLI for Claude AI)

**LaTeX distribution:**
| Package | Description |
|---------|-------------|
| texlive-basic | Core TeX Live with pdflatex |
| texlive-latex | LaTeX format and base packages |
| texlive-latexrecommended | Recommended packages (setspace, caption, booktabs) |
| texlive-latexextra | Additional packages (multirow, minted, glossaries) |
| texlive-binextra | Auxiliary programs (latexmk for VS Code) |

**Flutter SDK:**
- Automatic detection and download of latest stable release via Flutter API
- Installation directory: `~/development/flutter`
- Auto-adds to PATH in `.bashrc`
- Disables analytics by default
- Linux development dependencies (cmake, ninja)
- Android development setup:
  - JDK 17 (OpenJDK) via pacman
  - Android SDK, build tools, platform tools via AUR
  - Auto-copies SDK to `~/android-sdk` with proper ownership
  - Configures ANDROID_HOME, ANDROID_AVD_HOME, JAVA_HOME
  - Auto-accepts licenses and installs system images (Android 34 with Google Play)
  - Auto-updates all SDK components via `sdkmanager --update`
- Web development: CHROME_EXECUTABLE set to `/usr/bin/brave`
- **Note:** Full installation requires ~3-4GB disk space (including Android SDK)

## Complete keybindings reference

### Applications (SUPER + letter)
- **A**: Claude AI assistant
- **B**: Browser (Chromium)
- **C**: Visual Studio Code
- **D**: Docker (lazydocker in terminal)
- **F**: File manager (Nautilus)
- **G**: WhatsApp
- **H**: Homelab services dashboard
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
