# Omarchy automation reference

**Purpose**: Essential guidelines for automating Omarchy configurations.

---

## Critical components (DO NOT REMOVE)

### Hyprland & Wayland stack
- `hyprland`, `wayland`
- `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`
- `qt5-wayland`, `qt6-wayland`

### Essential tools
- `alacritty` - Terminal (used in keybindings)
- `neovim` - Editor (Omarchy menu depends on it)
- `chromium` - **CRITICAL**: Web apps functionality (not replaceable)
- `networkmanager`
- `pipewire` + `wireplumber`

---

## Omarchy-specific paths

```
~/.config/omarchy/themes/    # Pre-configured themes
~/.config/hypr/hyprland.conf # Main config (DO NOT DELETE)
~/bin/                       # Omarchy scripts
```

---

## Omarchy update architecture

### How updates work
Omarchy uses **git** for updates. The installation lives in `~/.local/share/omarchy/` (a git repository tracking `https://github.com/basecamp/omarchy.git`). When you click the update icon, Omarchy runs:
```bash
git -C ~/.local/share/omarchy pull --autostash
```

### CRITICAL: File system zones

**SAFE ZONE (User customizations - never touched by updates):**
- `~/.config/hypr/bindings.conf` - Custom keybindings
- `~/.config/hypr/monitors.conf` - Monitor configuration
- `~/.config/hypr/input.conf` - Input settings
- `~/.config/hypr/envs.conf` - Environment variables
- `~/.config/hypr/looknfeel.conf` - Look and feel
- `~/.config/hypr/autostart.conf` - Autostart applications
- `~/.local/share/applications/*.desktop` - Custom app launchers
- `~/.local/share/applications/icons/*` - Custom app icons
- All standard user config paths (`~/.config/*`, `~/.cache/*`, etc.)

**DANGER ZONE (Omarchy git repository - NEVER modify with Ansible):**
- `~/.local/share/omarchy/` - **DO NOT TOUCH!**
  - `bin/` - Scripts managed by Omarchy
  - `applications/` - Default app configurations
  - `default/hypr/` - Default Hyprland configs
  - `config/` - Default application configs

### How Hyprland config layering works
See `~/.config/hypr/hyprland.conf`:
1. **First**: Loads Omarchy defaults from `~/.local/share/omarchy/default/hypr/`
2. **Then**: Loads user overrides from `~/.config/hypr/` (overwrites defaults)

This means:
- ✅ Put custom keybindings in `~/.config/hypr/bindings.conf`
- ❌ NEVER modify `~/.local/share/omarchy/default/hypr/bindings/`

### Ansible best practices for Omarchy

**DO:**
- ✅ Create/modify files in `~/.config/hypr/`
- ✅ Create desktop files in `~/.local/share/applications/`
- ✅ Use `xdg-settings set default-web-browser` to set browser
- ✅ Modify user config files (`~/.config/*`, `~/.mozilla/*`, etc.)

**DON'T:**
- ❌ NEVER modify files in `~/.local/share/omarchy/`
- ❌ NEVER use `git` commands in `~/.local/share/omarchy/`
- ❌ NEVER create/delete files in Omarchy's git repository

**Why:** Modifying the Omarchy git repository causes merge conflicts during updates, breaking the update system.

**Setting default browser:**
```yaml
# CORRECT - Uses xdg-settings (for general browser usage)
- name: Set system default browser using xdg-settings
  ansible.builtin.command:
    cmd: xdg-settings set default-web-browser brave-browser.desktop

# WRONG - Modifies Omarchy git repository
- name: Modify omarchy-launch-webapp script
  ansible.builtin.template:
    dest: "~/.local/share/omarchy/bin/omarchy-launch-webapp"  # ❌ BAD!
```

**Overriding Omarchy scripts (advanced pattern):**

If you need to override Omarchy scripts behavior (e.g., force Brave for webapps), use the **PATH override pattern**:

1. `~/.local/bin` appears **before** `~/.local/share/omarchy/bin/` in PATH
2. Create wrapper script in `~/.local/bin/` with same name
3. Your script executes instead of Omarchy's default

Example - Force Brave for web apps:
```yaml
# Create wrapper script in ~/.local/bin (takes precedence via PATH)
- name: Ensure ~/.local/bin directory exists
  ansible.builtin.file:
    path: "{{ ansible_env.HOME }}/.local/bin"
    state: directory
    mode: '0755'

- name: Deploy wrapper script to use Brave for web apps
  ansible.builtin.copy:
    src: omarchy-launch-webapp
    dest: "{{ ansible_env.HOME }}/.local/bin/omarchy-launch-webapp"
    mode: '0755'
```

This pattern:
- ✅ Doesn't modify Omarchy git repository
- ✅ Survives Omarchy updates
- ✅ Can be version controlled in your Ansible repo
- ✅ Follows Linux PATH precedence conventions

---

## Key features

### Application launcher (walker)
- **Access**: `Super + Space`
- **Behavior**: Apps with `.desktop` files in `/usr/share/applications/` or `~/.local/share/applications/` appear automatically
- **When installing with pacman**: GUI apps appear automatically if they include a `.desktop` file (most do)
- **Web apps**: Added via Omarchy menu (`Install > Web App`)

### Critical keybindings (DO NOT CHANGE)
- `Super + Space` - Application launcher
- `Super + Alt + Space` - Omarchy menu
- `Super + Return` - Terminal (alacritty)

### System keybindings (DO NOT OVERRIDE)
These are universal commands that conflict with app shortcuts:
- `Super + C` - Universal Copy (clipboard.conf)
- `Super + V` - Universal Paste (clipboard.conf)
- `Super + X` - Universal Cut (clipboard.conf)
- `Super + Ctrl + V` - Clipboard history (clipboard.conf)
- `Super + F` - Force fullscreen (tiling-v2.conf)
- `Super + T` - Toggle floating window (tiling-v2.conf)
- `Super + G` - Toggle window grouping (tiling-v2.conf)

### Complete keybindings reference

**Applications (SUPER + letter):**
- A: Claude AI assistant
- B: Browser (Chromium)
- D: Docker (lazydocker in terminal)
- E: Thunderbird email client
- H: Homelab services dashboard
- M: Music (Spotify)
- N: Editor (Neovim)
- O: Obsidian
- R: Voice recording (Whispering toggle)
- Y: YouTube
- /: Passwords (Bitwarden)

**Applications that MUST keep SHIFT (conflicts with system commands):**
- Shift + C: Visual Studio Code (conflicts with universal Copy)
- Shift + F: File manager (Nautilus) (conflicts with Fullscreen)
- Shift + G: WhatsApp (conflicts with Toggle grouping)
- Shift + T: Activity monitor (btop in terminal) (conflicts with Toggle floating)

**Browser shortcuts:**
- B: Browser (normal mode)
- Alt + B: Browser (private mode)

**Menus and utilities:**
- Space: Application launcher (walker)
- Alt + Space: Omarchy menu
- K: Show key bindings
- Escape: Power menu
- Ctrl + E: Emoji picker

**Window management:**
- Return: Terminal (Alacritty)
- W: Close active window
- T: Toggle floating window
- F: Force full screen
- Alt + F: Full width
- J: Toggle split direction
- P: Pseudo window (dwindle)
- G: Toggle window grouping
- Alt + G: Move active window out of group
- Arrow keys: Move focus
- Shift + Arrow keys: Swap windows
- Alt + Arrow keys: Move window into group
- 1-0: Switch to workspace 1-10
- Shift + 1-0: Move window to workspace 1-10
- Tab: Next workspace
- Shift + Tab: Previous workspace
- Ctrl + Tab: Former workspace
- Alt + Tab: Cycle to next window
- Alt + Shift + Tab: Cycle to previous window

**Resize and move floating windows:**
NOTE: These commands work only on floating windows (toggle with Super + T)
- \- (minus): Reduce window width (100px)
- = (equals): Increase window width (100px)
- Shift + -: Reduce window height (100px)
- Shift + =: Increase window height (100px)
- Left mouse + drag: Move window (while holding Super)
- Right mouse + drag: Resize window (while holding Super)

**Available for new bindings:** I, L, Q, S, U, Z (simple SUPER + letter) | C, F, G, T already in use with SHIFT (must keep SHIFT) | X reserved for Cut

### Reload Hyprland
```bash
hyprctl reload
```

---

## Installing apps

### Via pacman/yay
- Apps appear automatically in launcher if they have `.desktop` file
- No special Omarchy configuration needed

### Custom .desktop files
- Place in `~/.local/share/applications/`
- Standard XDG Desktop Entry format
- Launcher picks them up automatically

### Web apps
- Use Omarchy menu: `Super + Alt + Space > Install > Web App`
- Requires: app name, URL, icon URL

---

## Ansible role architecture

### Organization principle: Group by installation technology, not semantic category

**IMPORTANT**: Always organize role variables and tasks by installation method (pacman, AUR, pipx, npm, etc.), NOT by semantic category (Python tools, LaTeX packages, etc.).

**Why**: This eliminates code repetition and follows DRY (Don't Repeat Yourself) principle.

**Example structure**:

```yaml
# vars/main.yml - Group by installation technology
pacman_packages_to_install:
  - name: python-pipx
    description: "..."
  - name: plantuml
    description: "..."
  - name: texlive-basic
    description: "..."

aur_packages_to_install:
  - name: android-sdk
    description: "..."

pipx_packages_to_install:
  - name: mistral-pdf-to-markdown
    description: "..."
```

```yaml
# tasks/main.yml - One task per installation technology
- name: Install packages via pacman
  community.general.pacman:
    name: "{{ item.name }}"
  loop: "{{ pacman_packages_to_install }}"

- name: Install packages via AUR
  kewlfft.aur.aur:
    name: "{{ item.name }}"
  loop: "{{ aur_packages_to_install }}"
```

**Don't do this** (anti-pattern):
```yaml
# BAD: Multiple separate tasks for the same technology
- name: Install Python tools via pacman
  loop: "{{ python_tools }}"

- name: Install LaTeX packages via pacman
  loop: "{{ latex_packages }}"

- name: Install diagram tools via pacman
  loop: "{{ diagram_tools }}"
```

---

## Automation principles

1. **NEVER touch `~/.local/share/omarchy/`** - It's a git repository managed by Omarchy updates
2. **Always backup configs** before modifying
3. **Don't remove**: Neovim, Alacritty, Chromium
4. **Don't break keybindings**: `Super + Space`, `Super + Alt + Space`, system keybindings (C/V/X/F/T/G)
5. **Reload Hyprland** after config changes: `hyprctl reload`
6. **Respect Omarchy menu workflow** when deploying configs
7. **Test critical packages** after modifications
8. **Desktop entries**: Apps appear automatically in launcher if they have `.desktop` file
9. **Use SAFE ZONE paths** for all Ansible modifications (see "Omarchy update architecture")

---

**Document version**: 7.0
**Last updated**: 2025-10-20
**Target Omarchy version**: 3.1.1
