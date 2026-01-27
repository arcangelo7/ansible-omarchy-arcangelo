# Ansible Omarchy configuration

Ansible playbook for managing my Omarchy (Arch Linux + Hyprland) setup.

## Supported version

Omarchy 3.3.3

## Prerequisites

```bash
sudo pacman -S ansible
ansible-galaxy collection install kewlfft.aur
```

## Usage

Run the entire playbook:
```bash
ansible-playbook playbook.yml -K
```

Run specific roles by tag:
```bash
ansible-playbook playbook.yml --tags apps,hyprland -K
```

Skip a role:
```bash
ansible-playbook playbook.yml --skip-tags dev -K
```

Dry run:
```bash
ansible-playbook playbook.yml --check -K
```

A reboot is needed after the first run for kernel modules and system settings to take effect.

## Roles

| Tag | Role | Purpose |
|-----|------|---------|
| `bloatware` | bloatware_removal | Remove unwanted packages and files |
| `apps` | applications_install | Install packages via pacman, AUR, and web app desktop files |
| `hyprland` | hyprland_config | Deploy keybindings and Hyprland settings |
| `system` | system_settings | Monitor scaling, keyboard layout, shell integration |
| `btrfs` | btrfs_maintenance | BTRFS scrub/balance systemd timers |
| `apps-config` | applications_config | Browser policies, default apps, Thunderbird/Neovim config |
| `dev` | developer_tools | Python, Node.js, Flutter, Android SDK, LaTeX |

### bloatware_removal

Removes packages and files left over from default Omarchy. See `roles/bloatware_removal/vars/main.yml` for the full list.

### applications_install

Runs a full system upgrade, then installs pacman packages, AUR packages (via `yay`), and creates desktop files for web apps. A dedicated `aur_builder` user handles AUR builds. See `roles/applications_install/vars/main.yml` for the package lists.

### hyprland_config

Deploys custom keybindings (`bindings.conf`), sets up ydotool for Wayland automation, and creates the whispering-toggle script. After the first run, logout/login is needed for whispering-toggle. See `roles/hyprland_config/files/bindings.conf` for the keybindings reference.

### system_settings

Configures monitor scaling, keyboard layout (US International with dead keys), touchpad settings, and mise shell integration. Edit `group_vars/all/system_settings.yml` to customize.

### btrfs_maintenance

Sets up monthly BTRFS scrub and balance via systemd timers with low-priority scheduling.

### applications_config

Configures Firefox, Chromium, Brave, and Thunderbird via enterprise policies and user.js templates. Sets default browser and text editor. Deploys Neovim plugins and Ghostty terminal config. Hides dev tools from the app launcher. See `roles/applications_config/defaults/main.yml` for all settings.

### developer_tools

Installs development packages (Python tooling, LaTeX, pandoc, graphviz), Android SDK with Flutter, Node.js via mise, Claude Code, Flatpak, and snapd. See `roles/developer_tools/vars/main.yml` for the package lists.

## Host-specific configuration

Variables can be overridden per-host in `host_vars/<hostname>/` (highest priority), over `group_vars/all/` defaults, over `roles/*/defaults/main.yml`. The `host_vars/` directory is gitignored since each machine has its own config.
