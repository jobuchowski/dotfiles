-- https://wiki.hypr.land/Configuring/

----------------
--- MONITORS ---
----------------

-- See https://wiki.hypr.land/Configuring/Monitors/
require("monitors")

-------------------
--- MY PROGRAMS ---
-------------------

-- Set programs that you use
local terminal = "kitty"
local dropdown_terminal = "$HOME/.local/bin/seed-toggle-dropdown-terminal"
local run_menu = "rofi -show run"
local drun_menu = "rofi -show drun -show-icons"
local calc_menu = "rofi -show calc -modi calc -normalize-match -no-sort -theme-str 'entry { placeholder: \"Type a calculation\"; }'"
local power_menu = "$HOME/.local/bin/seed-widget-powermenu"
local options_window = "$HOME/.local/bin/seed-widget-options"
local usb_manager = "quickshell -p $HOME/.config/quickshell/apps/usb"
local browser = "firefox"
local bar = "waybar"
local lock = "$HOME/.local/bin/seed-lockscreen"
local idle = "hypridle"
local file_browser = "pcmanfm-qt"
local fullscreen_script = "$HOME/.local/bin/seed-fullscreen"
local screen_color_picker = "hyprpicker -a"
local palette_color_picker = "gcolor3"
local bluetooth_menu = "$HOME/.local/bin/seed-exec-floating-window kitty -o confirm_os_window_close=0 bluetui"

local audio_lower_volume = "$HOME/.local/bin/seed-audio lower"
local audio_raise_volume = "$HOME/.local/bin/seed-audio raise"
local audio_toggle_mute = "$HOME/.local/bin/seed-audio toggle-mute"
local brightness_up = "$HOME/.local/bin/seed-brightness up"
local brightness_down = "$HOME/.local/bin/seed-brightness down"
local touchpad_toggle = "$HOME/.local/bin/seed-toggle-touchpad"

local record_fullscreen = "$HOME/.local/bin/seed-record fullscreen"
local record_area = "$HOME/.local/bin/seed-record area"
local record_window = "$HOME/.local/bin/seed-record window"

local reload_configs = "$HOME/.local/bin/seed-reload-configs"

-----------------
--- AUTOSTART ---
-----------------

hl.on("hyprland.start", function ()
    hl.exec_cmd(bar)
    hl.exec_cmd(idle)
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("dunst -config ~/.config/dunst/config")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("$HOME/.config/hypr/scripts/startup.sh")
    -- Screen sharing:
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------

-- toolkit-specific scale
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- GDK apps scaling (for example: postman)
hl.env("GDK_SCALE", "2")


---------------------
--- LOOK AND FEEL ---
---------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,

        border_size = 1,

        -- https://wiki.hypr.land/Configuring/Basics/Variables/#variable-types for info about colors
        col = {
            active_border = {
                colors = {
                    "rgba(de9c1cee)",
                    "rgba(eb4e3cee)",
                },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "master",
    },

    -- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
    decoration = {
        rounding = 3,
        rounding_power = 4,

        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        -- https://wiki.hypr.land/Configuring/Basics/Variables/#blur
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/#curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/#spring
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/#general
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.79,
    bezier = "easeOutQuint",
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.1,
    bezier = "easeOutQuint",
    style = "popin 87%",
})
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 6,    bezier = "quick" })


-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
hl.workspace_rule({ workspace = "1", gaps_out = 10, gaps_in = 4 })
hl.window_rule({
    name  = "no-gaps-firefox",
    match = { class = "firefox" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "floating-nm-connection-editor",
    match = { initial_class = "nm-connection-editor" },
    float = true,
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
        force_split = 2,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "slave",
        drop_at_cursor = true,
        mfact = 0.50,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
        mouse_move_focuses_monitor = false,
    },

    cursor = {
        no_warps = true, -- don't move cursor in the middle of newly focused window
    },
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})



-------------
--- INPUT ---
-------------

-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        -- To switch keyboard layouts, add layout for example pl,me and:
        -- hyprctl switchxkblayout current next
        kb_layout = "pl",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 2,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        float_switch_override_focus = 0,

        touchpad = {
            natural_scroll = true,
            tap_to_click = false,
            clickfinger_behavior = true,
        },
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


-------------------
--- KEYBINDINGS ---
-------------------

-- Some keycodes are in below link. Take only the part after XKB_KEY_. For example: Return
-- https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- https://wiki.hypr.land/Configuring/Basics/Binds/
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(drun_menu))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(run_menu))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(calc_menu))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(power_menu))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(screen_color_picker))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(options_window))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(usb_manager, { float = true, center = true }))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(file_browser))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(palette_color_picker))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fullscreen_script))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(bluetooth_menu))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(record_fullscreen))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(record_area))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd(record_window))
-- Dropdown terminal (tilda-like)
hl.bind("F12", hl.dsp.exec_cmd(dropdown_terminal))

hl.bind("CTRL + Space", hl.dsp.exec_cmd("dunstctl close"))
hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("dunstctl close-all"))

hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(reload_configs))

hl.bind(mainMod .. " + grave", function()
    hl.config({
        cursor = {
            zoom_factor = 3.0,
        },
    })
end)

hl.bind(mainMod .. " + grave", function()
    hl.config({
        cursor = {
            zoom_factor = 1.0,
        },
    })
end, { release = true })

-- Move focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))


-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(audio_raise_volume), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(audio_lower_volume), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(audio_toggle_mute), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(brightness_up), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightness_down), { locked = true, repeating = true })
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd(touchpad_toggle), { locked = true, repeating = true })

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -m active --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Lock lid on close
hl.bind(
    "switch:Lid Switch",
    hl.dsp.exec_cmd("hyprlock --immediate"),
    { locked = true }
)

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

