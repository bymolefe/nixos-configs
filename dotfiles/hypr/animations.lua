-- -----------------------------------------------------
--  ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
--  █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█
--
--  name: "High"
--  credit: https://github.com/mylinuxforwork/dotfiles
-- -----------------------------------------------------
-- This file is meant to be loaded with require("animations") from
-- hyprland.lua. It performs the actual hl.curve()/hl.animation() calls
-- directly (Hyprland's real Lua animation API), so simply requiring it
-- is enough — nothing needs to read a return value.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

hl.config({ animations = { enabled = true } })

-- Custom bezier curves: hl.curve(name, { type = "bezier", points = { {x1,y1}, {x2,y2} } })
hl.curve("wind",   { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("winIn",  { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("winOut", { type = "bezier", points = { {0.2,  0.0}, {0.0, 1.0} } })
hl.curve("liner",  { type = "bezier", points = { {1,   0.5},  {1,   1}   } })

-- Animation leaves: hl.animation({ leaf = name, enabled = bool, speed = float, bezier = curve[, style = "..."] })
-- "default" below is one of Hyprland's built-in curves — no hl.curve() needed for it.
hl.animation({ leaf = "windows",      enabled = true, speed = 2,   bezier = "wind",    style = "slide" })
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 2,   bezier = "winIn",   style = "slide" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 1.5, bezier = "winOut",  style = "slide" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 1.5, bezier = "wind",    style = "slide" })
hl.animation({ leaf = "border",       enabled = true, speed = 0.3, bezier = "liner" })
hl.animation({ leaf = "borderangle",  enabled = true, speed = 20,  bezier = "liner",   style = "loop" })
hl.animation({ leaf = "fade",         enabled = true, speed = 2.5, bezier = "default" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 1.5, bezier = "wind" })
