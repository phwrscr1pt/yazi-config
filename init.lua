-- =============================================================================
--                         YAZI INIT.LUA
--                    Lua plugins and custom commands
-- =============================================================================
-- Location on Windows: %USERPROFILE%\.config\yazi\init.lua
-- Location on Linux/Mac: ~/.config/yazi/init.lua

-- Log when yazi starts (for debugging)
-- ya.log("Yazi started!")

-- =============================================================================
-- PLUGINS (install manually - see README.md)
-- =============================================================================

-- Helper function to safely load plugins
local function safe_require(name)
    local ok, plugin = pcall(require, name)
    if ok and plugin and plugin.setup then
        plugin:setup()
        return true
    end
    return false
end

-- git.yazi - Show git status in file list
safe_require("git")

-- full-border.yazi - Add full border around yazi
safe_require("full-border")

-- glow.yazi - Markdown preview (configured in yazi.toml)
-- Install glow: sudo apt install glow

-- =============================================================================
-- HEADER LINE - show user@hostname in header
-- =============================================================================
Header:children_add(function()
    if ya.target_family() ~= "unix" then
        return ui.Line {}
    end
    return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. " "):fg("cyan")
end, 500, Header.LEFT)

-- =============================================================================
-- STATUS LINE - show file owner
-- =============================================================================
Status:children_add(function()
    local h = cx.active.current.hovered
    if not h then
        return ui.Line {}
    end

    local owner = h.cha.owner
    if owner then
        return ui.Line {
            ui.Span(" "),
            ui.Span(owner.name):fg("magenta"),
            ui.Span(":"),
            ui.Span(owner.group):fg("blue"),
            ui.Span(" "),
        }
    end
    return ui.Line {}
end, 500, Status.RIGHT)

-- =============================================================================
-- LINEMODE - show file permissions in line
-- =============================================================================
function Linemode:permissions()
    local h = self._file.cha
    if not h then
        return ui.Line {}
    end

    local perm = h:permissions()
    if not perm then
        return ui.Line {}
    end

    return ui.Line {
        ui.Span(" "),
        ui.Span(perm):fg("gray"),
    }
end

-- =============================================================================
-- CUSTOM COMMANDS (callable via plugin --args='command')
-- =============================================================================

-- Smart archive extraction based on file extension
local function smart_extract()
    local hovered = cx.active.current.hovered
    if not hovered then
        ya.notify {
            title = "Extract",
            content = "No file selected",
            level = "warn",
            timeout = 3,
        }
        return
    end

    local name = tostring(hovered.url)
    local cmd

    -- Determine extraction command based on extension
    if name:match("%.tar%.gz$") or name:match("%.tgz$") then
        cmd = "tar -xzf"
    elseif name:match("%.tar%.bz2$") or name:match("%.tbz2?$") then
        cmd = "tar -xjf"
    elseif name:match("%.tar%.xz$") or name:match("%.txz$") then
        cmd = "tar -xJf"
    elseif name:match("%.tar$") then
        cmd = "tar -xf"
    elseif name:match("%.zip$") then
        cmd = "unzip"
    elseif name:match("%.rar$") then
        cmd = "unrar x"
    elseif name:match("%.7z$") then
        cmd = "7z x"
    elseif name:match("%.gz$") then
        cmd = "gunzip"
    elseif name:match("%.xz$") then
        cmd = "unxz"
    else
        ya.notify {
            title = "Extract",
            content = "Unknown archive type: " .. name,
            level = "error",
            timeout = 5,
        }
        return
    end

    ya.manager_emit("shell", {
        cmd .. ' "' .. name .. '"',
        block = true,
    })
end

-- Quick git operations
local function git_action(action)
    local commands = {
        status = "git status",
        diff = "git diff",
        log = "git log --oneline -20",
        pull = "git pull",
        push = "git push",
        add = "git add -A",
        commit = "git commit",
    }

    local cmd = commands[action]
    if cmd then
        ya.manager_emit("shell", { cmd, block = true })
    else
        ya.notify {
            title = "Git",
            content = "Unknown git action: " .. tostring(action),
            level = "error",
            timeout = 3,
        }
    end
end

-- Open project with all tools (VS Code + terminal)
local function open_project()
    local cwd = tostring(cx.active.current.cwd)
    -- Open in VS Code
    ya.manager_emit("shell", { 'code "' .. cwd .. '"', orphan = true })
end

-- Compress selected files
local function compress()
    local selected = cx.active.selected
    if #selected == 0 then
        ya.notify {
            title = "Compress",
            content = "No files selected",
            level = "warn",
            timeout = 3,
        }
        return
    end

    -- Use first file name as archive name
    ya.manager_emit("shell", {
        'zip -r "archive.zip" "$@"',
        block = true,
    })
end

-- =============================================================================
-- PLUGIN ENTRY POINT
-- =============================================================================
return {
    entry = function(_, args)
        local cmd = args[1]
        if cmd == "smart-extract" then
            smart_extract()
        elseif cmd == "git-status" then
            git_action("status")
        elseif cmd == "git-diff" then
            git_action("diff")
        elseif cmd == "git-log" then
            git_action("log")
        elseif cmd == "git-pull" then
            git_action("pull")
        elseif cmd == "git-push" then
            git_action("push")
        elseif cmd == "git-add" then
            git_action("add")
        elseif cmd == "open-project" then
            open_project()
        elseif cmd == "compress" then
            compress()
        end
    end,
}
