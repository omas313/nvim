-- Pull in the wezterm API
local wezterm                         = require 'wezterm'

-- This will hold the configuration.
local config                          = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme                   = "Catppuccin Mocha"

config.font                           = wezterm.font('Monospace', { weight = 'Regular', italic = false })

config.font_size                      = 14

config.window_padding                 = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 0,
}

config.window_background_opacity      = 0.95

config.window_decorations             = "RESIZE"

config.window_background_gradient     = {
    -- Can be "Vertical" or "Horizontal".  Specifies the direction
    orientation = 'Vertical',
    colors = {
        '#171322',
        '#171322',
        '#171322',
        '#111111',
        '#111111',
        '#000000',
    },

    -- "Linear", "Basis" and "CatmullRom" as supported.
    interpolation = 'Basis',
    -- How the colors are blended in the gradient.
    -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
    -- The default is "Rgb".
    blend = 'LinearRgb',
}

-- config.window_background_image     = '/home/pace/Pictures/anima.jpg'
--
-- config.window_background_image_hsb = {
--     brightness = 0.05,
--     hue = 1.0,
--     saturation = 1.0,
-- }

config.tab_bar_at_bottom              = true
config.use_fancy_tab_bar              = false
config.hide_tab_bar_if_only_one_tab   = true
config.show_new_tab_button_in_tab_bar = false
config.hide_mouse_cursor_when_typing  = true

config.initial_cols                   = 120
config.initial_rows                   = 200

config.warn_about_missing_glyphs      = false
config.window_close_confirmation      = "NeverPrompt"

local act                             = wezterm.action
config.leader                         = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys                           = {
    {
        key = 't',
        mods = 'LEADER',
        action = act.SpawnTab 'CurrentPaneDomain',
    },

    { key = 'l', mods = 'LEADER',       action = wezterm.action.ShowLauncher },

    {
        key = 'w',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentTab { confirm = true },
    },

    {
        key = 'b',
        mods = 'LEADER',
        action = wezterm.action.CharSelect {
            copy_on_select = true,
            copy_to = 'ClipboardAndPrimarySelection',
        },
    },

    {
        key = 'c',
        mods = 'LEADER',
        action = wezterm.action.ActivateCopyMode,
    },


    {
        key = 'h',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.SplitPane {
            direction = 'Right',
            size = { Percent = 50 },
        },
    },
    {
        key = 'v',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.SplitPane {
            direction = 'Down',
            size = { Percent = 50 },
        },
    },

    {
        key = 'w',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },

    {
        key = 'h',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Right',
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Up',
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = act.ActivatePaneDirection 'Down',
    },

    {
        key = 'p',
        mods = 'LEADER',
        action = wezterm.action.ActivateCommandPalette,
    },

    { key = '[', mods = 'LEADER', action = act.MoveTabRelative(-1) },
    { key = ']', mods = 'LEADER', action = act.MoveTabRelative(1) },

    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    {
        key = 'a',
        mods = 'LEADER|CTRL',
        action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
    },
}

for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'LEADER',
        action = act.ActivateTab(i - 1),
    })
end

local mux = wezterm.mux
wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- and finally, return the configuration to wezterm
return config
