# Yazi Configuration

Custom Yazi config with Neovim-style keybindings and OneDark theme.

## Files

```
├── yazi.toml      # Main settings (editor, preview, openers)
├── keymap.toml    # Key bindings
├── theme.toml     # OneDark color scheme
└── init.lua       # Lua plugins and custom commands
```

## Quick Install

### Linux / Kali (clone from GitHub)

```bash
# Clone directly to yazi config directory
git clone https://github.com/YOUR_USERNAME/yazi-config.git ~/.config/yazi

# Or if yazi config already exists, backup and replace
mv ~/.config/yazi ~/.config/yazi.bak
git clone https://github.com/YOUR_USERNAME/yazi-config.git ~/.config/yazi
```

### Windows

```powershell
# Clone to yazi config directory
git clone https://github.com/YOUR_USERNAME/yazi-config.git $env:USERPROFILE\.config\yazi
```

### Manual Install (without git)

**Linux/macOS:**
```bash
mkdir -p ~/.config/yazi
cp yazi.toml keymap.toml theme.toml init.lua ~/.config/yazi/
```

**Windows:**
```powershell
mkdir -Force $env:USERPROFILE\.config\yazi
Copy-Item *.toml,init.lua $env:USERPROFILE\.config\yazi\
```

## Key Bindings

These keybindings mirror your Neovim setup:

### Git Integration
| Key | Action |
|-----|--------|
| `Ctrl+g` | Open LazyGit |
| `gg` | Open LazyGit (like nvim `<leader>gg`) |
| `gs` | Git status |
| `gl` | Git log |
| `gd` | Git diff |

### Editor Integration
| Key | Action |
|-----|--------|
| `Ctrl+n` | Open nvim in current directory |
| `V` | Open selected files in nvim |
| `Enter` | Open with default editor (nvim) |

### Directory Shortcuts (g + key)
| Key | Action |
|-----|--------|
| `gh` | Go to home |
| `gc` | Go to ~/.config |
| `gD` | Go to Desktop |
| `gd` | Go to Downloads |
| `gp` | Go to ~/projects |
| `gw` | Go to D:/HS (your workspace) |
| `gn` | Go to nvim config |

### Bookmarks
| Key | Action |
|-----|--------|
| `'1` | M9-Unix-script |
| `'2` | nvim-config |

### File Operations
| Key | Action |
|-----|--------|
| `md` | Create file/directory |
| `Ctrl+x` | Make file executable |
| `ex` | Extract archive |

### Navigation
| Key | Action |
|-----|--------|
| `Ctrl+f` | Search with fd |
| `zh` or `Ctrl+h` | Toggle hidden files |
| `zp` | Toggle preview panel |

### Copy Paths
| Key | Action |
|-----|--------|
| `yp` | Copy absolute path |
| `yd` | Copy directory path |
| `yn` | Copy filename |

### Sorting
| Key | Action |
|-----|--------|
| `on` | Sort by natural order |
| `os` | Sort by size |
| `om` | Sort by modification time |
| `oe` | Sort by extension |
| `or` | Reverse sort |

## Theme

OneDark color scheme matching your Neovim:
- Blue (`#61afef`) - directories, TypeScript, Lua
- Yellow (`#e5c07b`) - Python, JavaScript
- Green (`#98c379`) - shell scripts, executables
- Red (`#e06c75`) - HTML, Rust, archives
- Magenta (`#c678dd`) - images, CSS, headers
- Cyan (`#56b6c2`) - Markdown, Go, audio

## Shell Wrapper (Recommended)

Add this to your `~/.bashrc` or PowerShell profile to cd on exit:

### Bash/Zsh
```bash
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

### PowerShell
```powershell
function yy {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if ($cwd -and $cwd -ne $pwd.Path) {
        Set-Location -Path $cwd
    }
    Remove-Item -Path $tmp
}
```

## Custom Lua Commands (init.lua)

The `init.lua` provides custom commands callable via keybindings:

| Command | Key | Description |
|---------|-----|-------------|
| `smart-extract` | `ex` | Auto-detect archive type and extract |
| `compress` | `cz` | Compress selected files to zip |
| `open-project` | `Ctrl+o` | Open current directory in VS Code |

### UI Enhancements

- **Header**: Shows `user@hostname` on Unix systems
- **Status**: Shows file owner:group on the right
- **Linemode**: Adds permissions display option

## Plugins

This config uses 3 plugins that need to be installed separately.

### Install Plugins (Linux/Kali)

**Option 1: Using `ya` (Yazi v0.4+)**
```bash
ya pack -a yazi-rs/plugins:git
ya pack -a yazi-rs/plugins:full-border
ya pack -a Reledia/glow.yazi
```

**Option 2: Manual Install (older Yazi versions)**
```bash
# Create plugins directory
mkdir -p ~/.config/yazi/plugins

# Clone plugins
git clone https://github.com/yazi-rs/plugins.git /tmp/yazi-plugins
cp -r /tmp/yazi-plugins/git.yazi ~/.config/yazi/plugins/
cp -r /tmp/yazi-plugins/full-border.yazi ~/.config/yazi/plugins/

git clone https://github.com/Reledia/glow.yazi.git ~/.config/yazi/plugins/glow.yazi

# Cleanup
rm -rf /tmp/yazi-plugins

# Install glow for markdown preview
sudo apt install glow
```

### Plugin Descriptions

| Plugin | Description |
|--------|-------------|
| **git.yazi** | Shows git status (modified/staged/untracked) in file list |
| **full-border.yazi** | Adds a full border around yazi for cleaner UI |
| **glow.yazi** | Preview markdown files with syntax highlighting |

## Requirements

- **Yazi** - terminal file manager
- **Nerd Font** - for icons (you likely have this for nvim)
- **fd** - for fast search (`Ctrl+f`)
- **bat** - for file preview (optional)
- **lazygit** - for git integration (`Ctrl+g`)
- **unzip/tar/7z** - for archive extraction
- **glow** - for markdown preview (install: `sudo apt install glow`)

## Hot Reload

Yazi supports hot reload! After editing config:
- Switch focus away and back, OR
- Press `Ctrl+r` to force reload
