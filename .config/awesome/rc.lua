-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

awful.spawn.with_shell("picom --experimental-backends")

beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/theme.lua")
beautiful.font = "Inter 10"

-- Paleta base (cai para gruvbox padrão se o theme não tiver)
local GB_DARK = beautiful.bg_normal
local GB_LIGHT = beautiful.fg_normal
local GB_ACCENT = beautiful.border_focus

-- Bordas claras (normal e foco iguais, como você pediu)
beautiful.border_width = beautiful.border_width or 1

-- Wibar herda do tema (seu theme pode já setar isso)
beautiful.wibar_bg = beautiful.wibar_bg or GB_DARK
beautiful.wibar_fg = beautiful.wibar_fg or GB_LIGHT

local function set_wallpaper(s)
	-- Fundo sólido usando a cor do tema
	local GB_DARK = beautiful.wibar_bg or beautiful.bg_normal or "#1d2021"
	gears.wallpaper.set(GB_DARK)
end

beautiful.wallpaper = set_wallpaper

local battery_widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
})

-- Função para atualizar a bateria
local function update_battery()
	awful.spawn.easy_async_with_shell(
		[[
        if [ -d /sys/class/power_supply/BAT0 ]; then
            cat /sys/class/power_supply/BAT0/capacity
        elif command -v acpi > /dev/null; then
            acpi -b | grep -oP '[0-9]+(?=%)'
        else
            echo "?"
        fi
        ]],
		function(out)
			local level = tonumber(out:match("%d+"))
			if level then
				battery_widget.text = "🔋 " .. level .. "%"
			else
				battery_widget.text = "⚠️ Bat"
			end
		end
	)
end

-- Atualiza a cada 30 segundos
gears.timer({
	timeout = 30,
	autostart = true,
	call_now = true,
	callback = update_battery,
})

-- Volume Slider Widget
local volume_slider = wibox.widget({
	bar_shape = gears.shape.rounded_rect,
	bar_height = 4,
	bar_color = beautiful.bg_minimize or beautiful.bg_normal, -- trilho
	bar_active_color = beautiful.border_focus or "#d79921", -- ativo/acento
	handle_color = beautiful.border_focus or "#d79921",
	handle_shape = gears.shape.circle,
	handle_width = 10,
	minimum = 0,
	maximum = 100,
	value = 50,
	widget = wibox.widget.slider,
})

-- Limita o tamanho do slider na barra (ex: 100px de largura)
local volume_container = wibox.container.constraint(volume_slider, "exact", 100)

-- Texto da porcentagem
local volume_percent = wibox.widget({
	widget = wibox.widget.textbox,
	text = "0%",
	align = "left",
	valign = "center",
})

-- Função para atualizar o valor do slider com volume atual do sistema
local function update_volume()
	awful.spawn.easy_async_with_shell("amixer get Master | grep -o '[0-9]*%' | head -1 | tr -d '%'", function(out)
		local vol = tonumber(out)
		if vol then
			volume_slider.value = vol
			volume_percent.text = vol .. "%"
		end
	end)
end

-- Atualiza volume ao mover o slider
volume_slider:connect_signal("property::value", function()
	local vol = math.floor(volume_slider.value)
	volume_percent.text = vol .. "%" -- 👈 atualiza o texto
	awful.spawn("amixer set Master " .. vol .. "%", false)
end)

-- Atualiza inicialmente e a cada 10 segundos
gears.timer({
	timeout = 10,
	autostart = true,
	call_now = true,
	callback = update_volume,
})

-- Botão "▼" na wibar
local dropdown_btn = wibox.widget({
	widget = wibox.widget.textbox,
	markup = "▼",
	align = "center",
	valign = "center",
})

-- ==== INFOS E WIDGETS DO DROPDOWN ====

-- Linha: Teclado
local kb_layout = wibox.widget({
	widget = wibox.widget.textbox,
	text = "…",
	align = "left",
	valign = "center",
})

local function update_keyboard_info()
	awful.spawn.easy_async_with_shell(
		[[
        L=$(setxkbmap -query | awk '/layout/ {print $2}')
        V=$(setxkbmap -query | awk '/variant/ {print $2}')
        if [ -n "$V" ]; then echo "$L ($V)"; else echo "$L"; fi
    ]],
		function(out)
			local layout = (out or ""):gsub("%s+$", "")
			if layout == "" then
				layout = "desconhecido"
			end
			kb_layout.text = layout
		end
	)
end

-- Linha: Wi‑Fi
local wifi_name = wibox.widget({ widget = wibox.widget.textbox, text = "disconnected", align = "left" })
local wifi_status = wibox.widget({ widget = wibox.widget.textbox, text = "❌", align = "right" })

local function update_network_info()
	awful.spawn.easy_async_with_shell(
		[[
        if command -v nmcli >/dev/null 2>&1; then
            SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes"{print $2; exit}')
            if [ -z "$SSID" ]; then SSID=$(nmcli -t -f NAME connection show --active | head -n1); fi
            CONN=$(nmcli -t -f CONNECTIVITY general status 2>/dev/null | head -n1)
        else
            SSID=$(iwgetid -r 2>/dev/null)
            if ping -q -w1 -c1 1.1.1.1 >/dev/null; then CONN=full; else CONN=none; fi
        fi
        [ -z "$SSID" ] && SSID="disconnected"
        echo "$SSID|$CONN"
    ]],
		function(out)
			local ssid, conn = (out or ""):match("^(.*)|(%S+)")
			ssid = (ssid or ""):gsub("%s+$", "")
			conn = conn or "none"
			wifi_name.text = ssid ~= "" and ssid or "disconnected"
			if ssid == "disconnected" or conn == "none" then
				wifi_status.text = "❌"
			elseif conn == "full" then
				wifi_status.text = "✅"
			else
				wifi_status.text = "⚠️"
			end
		end
	)
end

-- Linha: Bateria
local battery_pct = wibox.widget({ widget = wibox.widget.textbox, text = "--%", align = "right" })

local function update_battery_dropdown()
	awful.spawn.easy_async_with_shell(
		[[
        if [ -d /sys/class/power_supply/BAT0 ]; then
            cat /sys/class/power_supply/BAT0/capacity
        elif command -v acpi > /dev/null; then
            acpi -b | grep -oP '[0-9]+(?=%)'
        else
            echo ""
        fi
    ]],
		function(out)
			local level = tonumber((out or ""):match("%d+"))
			if level then
				battery_pct.text = level .. "%"
			else
				battery_pct.text = "?"
			end
		end
	)
end

-- Volume (% já existe como 'volume_percent' e slider como 'volume_slider')
-- (garante atualização em tempo real já no seu handler existente)

-- Botões de energia
local function txtbtn(markup, cb)
	local b = wibox.widget({
		widget = wibox.widget.textbox,
		markup = markup,
		align = "center",
		valign = "center",
	})
	b:buttons(gears.table.join(awful.button({}, 1, cb)))
	return b
end

local poweroff_btn = txtbtn("⏻ Desligar", function()
	awful.spawn.with_shell("systemctl poweroff")
end)
local restart_btn = txtbtn("🔄 Reiniciar", function()
	awful.spawn.with_shell("systemctl reboot")
end)
local logout_btn = txtbtn("🚪 Logout", function()
	awesome.quit()
end)
local hibernate_btn = txtbtn("🌙 Hibernar", function()
	awful.spawn.with_shell("systemctl hibernate")
end)

-- Cabeçalhos e separadores
local header_settings = wibox.widget({ widget = wibox.widget.textbox, markup = "<b>Settings</b>" })
local header_status = wibox.widget({ widget = wibox.widget.textbox, markup = "<b>Status</b>" })
local sep = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	thickness = 1,
	color = beautiful.fg_normal,
	forced_height = 1,
})

-- ====== LAYOUT DO DROPDOWN (como você especificou) ======
-- Settings
-- 🔊 Volume:
-- [slider...................]        [NN%]
-- 📶 Wifi
-- <network_name> / "disconnected"    <status icon>
-- -----------------------------------------
-- Status
-- 🔋 Battery:                         NN%
-- ⌨️  Teclado:                        <layout>
-- -----------------------------------------
-- ⏻ | 🔄 | 🚪 | 🌙
local dropdown_content = wibox.widget({
	-- Settings
	{ header_settings, left = 10, right = 10, top = 8, bottom = 2, widget = wibox.container.margin },

	{ -- "🔊 Volume:"
		{
			{ widget = wibox.widget.textbox, markup = "🔊  Volume:" },
			layout = wibox.layout.fixed.horizontal,
		},
		left = 10,
		right = 10,
		top = 4,
		bottom = 0,
		widget = wibox.container.margin,
	},
	{ -- slider + %
		{
			wibox.container.constraint(volume_slider, "exact", 200, 14),
			nil,
			volume_percent,
			layout = wibox.layout.align.horizontal,
		},
		left = 10,
		right = 10,
		top = 2,
		bottom = 8,
		widget = wibox.container.margin,
	},

	{ -- "📶 Wifi"
		{
			{ widget = wibox.widget.textbox, markup = "📶  Wifi" },
			layout = wibox.layout.fixed.horizontal,
		},
		left = 10,
		right = 10,
		top = 0,
		bottom = 0,
		widget = wibox.container.margin,
	},
	{ -- <network_name> ..... <status icon>
		{
			wifi_name,
			nil,
			wifi_status,
			layout = wibox.layout.align.horizontal,
		},
		left = 10,
		right = 10,
		top = 2,
		bottom = 8,
		widget = wibox.container.margin,
	},

	sep,

	-- Status
	{ header_status, left = 10, right = 10, top = 8, bottom = 2, widget = wibox.container.margin },

	{ -- 🔋 Battery: .... NN%
		{
			{
				{ widget = wibox.widget.textbox, markup = "🔋  Battery:" },
				layout = wibox.layout.fixed.horizontal,
			},
			nil,
			battery_pct,
			layout = wibox.layout.align.horizontal,
		},
		left = 10,
		right = 10,
		top = 4,
		bottom = 4,
		widget = wibox.container.margin,
	},

	{ -- ⌨️ Teclado: .... <layout>
		{
			{
				{ widget = wibox.widget.textbox, markup = "⌨️  Teclado:" },
				layout = wibox.layout.fixed.horizontal,
			},
			nil,
			kb_layout,
			layout = wibox.layout.align.horizontal,
		},
		left = 10,
		right = 10,
		top = 2,
		bottom = 8,
		widget = wibox.container.margin,
	},

	sep,

	{ -- botões de energia
		{
			poweroff_btn,
			{ widget = wibox.widget.textbox, markup = " | " },
			restart_btn,
			{ widget = wibox.widget.textbox, markup = " | " },
			logout_btn,
			{ widget = wibox.widget.textbox, markup = " | " },
			hibernate_btn,
			spacing = 6,
			layout = wibox.layout.fixed.horizontal,
		},
		left = 10,
		right = 10,
		top = 8,
		bottom = 8,
		widget = wibox.container.margin,
	},

	spacing = 0,
	layout = wibox.layout.fixed.vertical,
})

-- Popup com TODO o conteúdo (Settings + Status + Botões)
local dropdown_popup = awful.popup({
	widget = wibox.widget({
		{
			dropdown_content,
			margins = 6,
			widget = wibox.container.margin,
		},
		bg = beautiful.bg_normal,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 8)
		end,
		widget = wibox.container.background,
	}),
	ontop = true,
	visible = false,
	shape = gears.shape.rounded_rect,
	border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	maximum_width = 360,
	maximum_height = 320,
})

-- Fecha automaticamente quando o mouse sai de cima do popup
dropdown_popup:connect_signal("mouse::leave", function()
	dropdown_popup.visible = false
end)

-- Clique no botão: alterna o popup e atualiza o texto
dropdown_btn:buttons(gears.table.join(awful.button({}, 1, function()
	update_keyboard_info()
	update_network_info()
	update_battery_dropdown()
	update_volume()

	local s = awful.screen.focused()
	local top_gap = (s.mywibox and s.mywibox.height or 0) + 10

	awful.placement.top_right(dropdown_popup, {
		parent = s,
		margins = { top = top_gap, right = 8 },
	})

	dropdown_popup.visible = not dropdown_popup.visible
end)))

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = { { "awesome", myawesomemenu, beautiful.awesome_icon }, { "open terminal", terminal } },
})

mylauncher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = mymainmenu,
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		bg = beautiful.wibar_bg,
		fg = beautiful.wibar_fg,
	})

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			--mylauncher,
			s.mypromptbox,
		},
		-- Centro real: relógio centralizado na tela
		wibox.widget({
			{
				mytextclock,
				layout = wibox.layout.align.horizontal,
				expand = "none",
			},
			halign = "center",
			valign = "center",
			widget = wibox.container.place,
		}),
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			battery_widget,
			dropdown_btn,
		},
	})
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ modkey }, "r", function()
		awful.screen.focused().mypromptbox:run()
	end, { description = "run prompt", group = "launcher" }),

	awful.key({ modkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" }),
	-- Menubar
	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" })
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = false },
	},

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Rounded borders
client.connect_signal("manage", function(c)
	c.shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 10)
	end
end)

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("request::titlebars", function(c)
	awful.titlebar.hide(c)
end)

-- Muda cor da borda ao focar/desfocar
client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- }}}
