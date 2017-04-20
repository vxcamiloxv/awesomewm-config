--[[

   Awesome WM Configuration 1.1
   Distopico Vegan <distopico [at] riseup [dot] net>
   Licensed under GPL3

--]]

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Aditional libraries
local cyclefocus = require("libs/cyclefocus")

require("awful.autofocus")
awful.rules = require("awful.rules")

--
-- Custom widgets
local myvolume = require("widgets/volume")
local mybrightness = require("widgets/brightness")
local mybattery = require("widgets/battery")
local mywifi = require("widgets/wifi")
local mycpufreq = require("widgets/cpufreq")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal(
      "debug::error", function (err)
         -- Make sure we don't go into an endless error loop
         if in_error then return end
         in_error = true

         naughty.notify({ preset = naughty.config.presets.critical,
                          title = "Oops, an error happened!",
                          text = tostring(err) })
         in_error = false
   end)
end
-- }}}

-- Cyclefocus
cyclefocus.raise_clients = false
cyclefocus.focus_clients = false
cyclefocus.display_prev_count = 1
cyclefocus.naughty_preset = {
   position = "top_left",
   timeout = 0,
   margin = 3,
   border_width = 1,
   border_color = "#001E21",
   fg = "#00ffff",
   bg = "#001214"
}
naughty.config.defaults.fg = "#6F6F6F"
naughty.config.defaults.bg = "#ffffff"
naughty.config.defaults.width = 300
naughty.config.defaults.icon_size = 30

-- {{{ Variable definitions
wallmenu = {}

--Configure home path so you dont have too
home_path  = os.getenv("HOME") .. "/"
-- Themes define colours, icons, font and wallpapers.
beautiful.init(home_path .. "/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc" or "urxvt" or "terminator" or "gnome-terminal" or "xterm"
editor = os.getenv("EDITOR") or "nano" or "emacs" or "editor"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser    = "iceweasel"
browser2   = "inox"
gui_editor = "gedit"
graphics   = "gimp"
musicplr   = terminal .. " -e ncmpcpp "

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"


-- {{{ Helper functions
local function client_menu_toggle_fn()
   local instance = nil

   return function ()
      if instance and instance.wibox.visible then
         instance:hide()
         instance = nil
      else
         instance = awful.menu.clients({ theme = { width = 250 } })
      end
   end
end

local system_lock = function ()
   awful.spawn("xdg-screensaver lock")
   --[[
   dbus-send --session --dest=org.freedesktop.ScreenSaver --type=method_call
   --print-reply --reply-timeout=20000 /ScreenSaver org.freedesktop.ScreenSaver.Lock
   --]]
end

local system_suspend = function ()
   awful.spawn("systemctl suspend")
end

local system_hibernate = function ()
   awful.prompt.run {
      prompt       = "Hibernate (type 'yes' to confirm)? ",
      textbox      = awful.screen.focused().mypromptbox.widget,
      exe_callback = function (t)
         if string.lower(t) == "yes" then
            awful.spawn("systemctl hibernate")
         end
      end,
      completion_callback = function (t, p, n)
         return awful.completion.generic(t, p, n, {"no", "NO", "yes", "YES"})
      end
   }
end

local system_hybrid_sleep = function ()
   awful.prompt.run {
      prompt       = "Hybrid Sleep (type 'yes' to confirm)? ",
      textbox      = awful.screen.focused().mypromptbox.widget,
      exe_callback = function (t)
         if string.lower(t) == "yes" then
            awful.spawn("systemctl hybrid-sleep")
         end
      end,
      completion_callback = function (t, p, n)
         return awful.completion.generic(t, p, n, {"no", "NO", "yes", "YES"})
      end
   }
end

local system_reboot = function ()
   awful.prompt.run {
      prompt       = "Reboot (type 'yes' to confirm)? ",
      textbox      = awful.screen.focused().mypromptbox.widget,
      exe_callback = function (t)
         if string.lower(t) == "yes" then
            awesome.emit_signal("exit", nil)
            awful.spawn("systemctl reboot")
         end
      end,
      completion_callback = function (t, p, n)
         return awful.completion.generic(t, p, n, {"no", "NO", "yes", "YES"})
      end
   }
end

local system_power_off = function ()
   awful.prompt.run {
      prompt       = "Power Off (type 'yes' to confirm)? ",
      textbox      = awful.screen.focused().mypromptbox.widget,
      exe_callback = function (t)
         if string.lower(t) == "yes" then
            awesome.emit_signal("exit", nil)
            awful.spawn("systemctl poweroff")
         end
      end,
      completion_callback = function (t, p, n)
         return awful.completion.generic(t, p, n, {"no", "NO", "yes", "YES"})
      end
   }
end

local wall_load = function(wall)
   local f = io.popen("ln -sfn " .. home_path .. "Pictures/Wallpapers/" .. wall .. " " .. home_path .. ".config/awesome/theme/_wall.jpg")
   awesome.restart()
end

local wall_menu = function()
   local f = io.popen("ls -1 " .. home_path .. "Pictures/Wallpapers/")
   for l in f:lines() do
      local item = { l, function () wall_load(l) end }
      table.insert(wallmenu, item)
   end
   table.insert(wallmenu, {
                   "Default",
                   function ()
                      awful.spawn.with_shell("rm " .. home_path .. ".config/awesome/theme/_wall.jpg")
                      awesome.restart() end})
   f:close()
end

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

--}}}

-- Table of layouts to cover with awful.layout.inc, order matters.
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.fair.horizontal,
   awful.layout.suit.spiral,
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier,
   awful.layout.suit.corner.nw,
   -- awful.layout.suit.corner.ne,
   -- awful.layout.suit.corner.sw,
   -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Wallpaper menu
wall_menu()
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "&manual", terminal .. " -e man awesome" },
   { "&edit config", editor_cmd .. " " .. awesome.conffile },
   { "&restart", awesome.restart },
   { "&quit", function() awesome.quit() end}
}

mysystemmenu = {
   --{ "manual", tools.terminal .. " -e man awesome" },
   { "&lock", system_lock },
   { "&suspend", system_suspend },
   { "hi&bernate", system_hibernate },
   { "hybri&d sleep", system_hybrid_sleep },
   { "&reboot", system_reboot },
   { "&power off", system_power_off }
}

mymainmenu = awful.menu({
      items = {
         { "&Awesome", myawesomemenu, beautiful.menu_icon },
         { "&System", mysystemmenu },
         { "&Wallpapers", wallmenu },
         { "&Terminal", terminal }
      }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
app_folders =  { "~/.local/share/applications", "/usr/share/applications/", "/usr/local/share/applications" }
menubar.menu_gen.all_menu_dirs = app_folders
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end),
   awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
               c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 3, client_menu_toggle_fn()),
   awful.button({ }, 4, function ()
         awful.client.focus.byidx(1)
   end),
   awful.button({ }, 5, function ()
         awful.client.focus.byidx(-1)
end))


awful.screen.connect_for_each_screen(function(s)
      -- Widgets separators
      local separator1px = wibox.widget.imagebox()
      separator1px:set_image(beautiful.get().spr1px)
      local separator2px = wibox.widget.imagebox()
      separator2px:set_image(beautiful.get().spr2px)
      local separator4px = wibox.widget.imagebox()
      separator4px:set_image(beautiful.get().spr4px)
      local separator5px = wibox.widget.imagebox()
      separator5px:set_image(beautiful.get().spr5px)
      local separator10px = wibox.widget.imagebox()
      separator10px:set_image(beautiful.get().spr10px)

      -- Wallpaper
      set_wallpaper(s)

      -- Each screen has its own tag table.
      layouts = awful.layout.layouts
      tags = {
         names = { "1", "2", "3", "4", "5", "6" },
         layouts = { layouts[1], layouts[2], layouts[10], layouts[10], layouts[1], layouts[12] }
      }
      awful.tag(tags.names, s, tags.layouts)

      -- Create a promptbox for each screen
      s.mypromptbox = awful.widget.prompt()
      -- Create an imagebox widget which will contains an icon indicating which layout we're using.
      -- We need one layoutbox per screen.
      s.mylayoutbox = awful.widget.layoutbox(s)
      s.mylayoutbox:buttons(awful.util.table.join(
                               awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                               awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                               awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                               awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
      -- Create a taglist widget
      s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

      -- Create a tasklist widget
      s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

      -- Create a systray widget
      local mysystray = wibox.widget.systray()
      local mysystraymargin = wibox.layout.margin()
      mysystraymargin:set_margins(4)
      mysystraymargin:set_widget(mysystray)

      -- Create the wibox
      s.mywibox = awful.wibox({ position = "top", screen = s })

      -- Widgets that are aligned to the left
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(mylauncher)
      left_layout:add(s.mytaglist)
      left_layout:add(s.mypromptbox)
      left_layout:add(separator10px)

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(mysystraymargin)
      right_layout:add(separator2px)
      right_layout:add(mykeyboardlayout)
      right_layout:add(separator2px)
      right_layout:add(mycpufreq.text)
      right_layout:add(separator2px)
      right_layout:add(myvolume.icon)
      right_layout:add(separator1px)
      right_layout:add(mybrightness.icon)

      if mybattery.hasbattery then
         right_layout:add(separator1px)
         right_layout:add(mybattery.icon)
      end

      if mywifi.haswifi then
         right_layout:add(separator1px)
         right_layout:add(mywifi.icon)
      end

      right_layout:add(mytextclock)
      right_layout:add(s.mylayoutbox)

      -- Add widgets to the wibox
      s.mywibox:setup {
         layout = wibox.layout.align.horizontal,
         left_layout,  -- Left widget
         s.mytasklist, -- Middle widget
         right_layout, -- Right widget
      }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
                awful.button({ }, 3, function () mymainmenu:toggle() end),
                awful.button({ }, 4, awful.tag.viewnext),
                awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
globalkeys = awful.util.table.join(
   -- help
   -- awful.key({ modkey,           }, "F1", keydoc.display),

   awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

   -- Non-empty tag browsing
   awful.key({ modkey,            }, "Prior",
      function () lain.util.tag_view_nonempty(-1) end),
   awful.key({ modkey,            }, "Next",
      function () lain.util.tag_view_nonempty(1) end),

   -- Take a screenshot
   awful.key({                   }, "Print",
      function () awful.spawn("upload_screens scr") end),

   -- Default client focus
   awful.key({ modkey,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

   -- Layout manipulation
   -- keydoc.group("Layout manipulation"),
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
   awful.key({ modkey,           }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
   end),
   awful.key({ altkey,          }, "Tab", function(c)
         cyclefocus.cycle(1)
   end),
   awful.key({ altkey, "Shift"  }, "Tab", function(c)
         cyclefocus.cycle(-1)
   end),

   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

   awful.key({ modkey, "Control" }, "n", awful.client.restore),

   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
   awful.key({ modkey, "Control" }, "r", awesome.restart),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit),

   -- System volume
   awful.key({                   }, "XF86AudioRaiseVolume", myvolume.raise),
   awful.key({                   }, "XF86AudioLowerVolume", myvolume.lower),
   awful.key({                   }, "XF86AudioMute", myvolume.mute),

   -- System brightness
   awful.key({                   }, "XF86MonBrightnessDown", function() mybrightness:down() end),
   awful.key({                   }, "XF86MonBrightnessUp", function() mybrightness:up() end),

   -- Admin
   awful.key({ modkey,           }, "Home", system_lock),
   awful.key({ modkey,           }, "End", system_suspend),
   awful.key({ modkey, "Shift"   }, "Home", system_hibernate),
   awful.key({ modkey, "Shift"   }, "End", system_hybrid_sleep),
   awful.key({ modkey,           }, "Insert", system_reboot),
   awful.key({ modkey,           }, "Delete", system_power_off),
   awful.key({                   }, "XF86Sleep", system_suspend),
   awful.key({ modkey            }, "XF86Sleep", system_hibernate),


   -- Prompt
   awful.key({ modkey },            "r", function () awful.screen.focused().mypromptbox:run() end,
      {description = "run prompt", group = "launcher"}),

   awful.key({ modkey,           }, "x",
      function ()
         awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
         }
      end,
      {description = "lua execute prompt", group = "awesome"}),
   -- Menubar
   awful.key({ modkey          }, "|", function ()
         -- If you want to always position the menu on the same place set coordinates
         awful.menu.menu_keys.down = { "Down", "Alt_L" }
         awful.menu.clients({theme = { width = 250 }}, { keygrabber=true, coords={x=525, y=330} })
   end),
   awful.key({ modkey,         }, "a", function () awful.spawn("rofi -show", false) end),
   awful.key({ modkey,         }, "p", function() menubar.show() end),
   awful.key({ modkey,         }, "w", function () mymainmenu:show() end),
   awful.key({ modkey, "Shift" }, "p",
      function ()
         mymainmenu:show({ keygrabber = true })
   end)
)

clientkeys = awful.util.table.join(
   awful.key({ modkey,  "Shift"  }, "Left",   function (c) awful.client.setmaster(c)        end),
   awful.key({ modkey,  "Shift"  }, "Right",  function (c) awful.client.setslave(c)         end),
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ altkey,           }, "F4",     function (c) c:kill()                         end),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey, "Shift"   }, "t",      awful.titlebar.toggle),
   awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky          end),
   awful.key({ modkey,           }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
   end),
   awful.key({ modkey,           }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c.maximized_vertical   = not c.maximized_vertical
   end),
   awful.key({ modkey, "Shift"   }, "m", function (c)
         c.minimized = not c.minimized
   end),
   awful.key({ modkey, "Shift"   }, "h",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
   end),

   awful.key({ modkey, "Shift"   }, "v",
      function(c)
         c.maximized_vertical   = not c.maximized_vertical
   end),
   -- Snap
   awful.key({ modkey,           }, "Up",
      function (c)
         c.maximized_horizontal = true
         c.maximized_vertical   = true
   end),
   awful.key({ modkey,           }, "Down",
      function (c)
         c.maximized_horizontal = false
         c.maximized_vertical   = false
         awful.placement.centered(c,nil)
   end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   globalkeys = awful.util.table.join(globalkeys,
                                      -- View tag only.
                                      awful.key({ modkey }, "#" .. i + 9,
                                         function ()
                                            local screen = awful.screen.focused()
                                            local tag = screen.tags[i]
                                            if tag then
                                               tag:view_only()
                                            end
                                         end,
                                         {description = "view tag #"..i, group = "tag"}),
                                      -- Toggle tag display.
                                      awful.key({ modkey, "Control" }, "#" .. i + 9,
                                         function ()
                                            local screen = awful.screen.focused()
                                            local tag = screen.tags[i]
                                            if tag then
                                               awful.tag.viewtoggle(tag)
                                            end
                                         end,
                                         {description = "toggle tag #" .. i, group = "tag"}),
                                      -- Move client to tag.
                                      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                         function ()
                                            if client.focus then
                                               local tag = client.focus.screen.tags[i]
                                               if tag then
                                                  client.focus:move_to_tag(tag)
                                               end
                                            end
                                         end,
                                         {description = "move focused client to tag #"..i, group = "tag"}),
                                      -- Toggle tag on focused client.
                                      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                         function ()
                                            if client.focus then
                                               local tag = client.focus.screen.tags[i]
                                               if tag then
                                                  client.focus:toggle_tag(tag)
                                               end
                                            end
                                         end,
                                         {description = "toggle focused client on tag #" .. i, group = "tag"})
   )
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}
function titlebar_add(c)
   if c.type == "normal" or c.type == "dialog" then
      -- buttons for the titlebar
      local buttons = awful.util.table.join(
         awful.button({ }, 1, function()
               client.focus = c
               c:raise()
               awful.mouse.client.move(c)
         end),
         awful.button({ }, 3, function()
               client.focus = c
               c:raise()
               awful.mouse.client.resize(c)
         end)
      )

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      -- The title goes in the middle
      local middle_layout = wibox.layout.flex.horizontal()
      local title = awful.titlebar.widget.titlewidget(c)
      title:set_align("center")
      middle_layout:add(title)
      middle_layout:buttons(buttons)

      -- Now bring it all together
      local layout = wibox.layout.align.horizontal()
      layout:set_right(right_layout)
      layout:set_middle(middle_layout)

      awful.titlebar(c,{size=16}):set_widget(layout)
   end
end

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        titlebars_enabled = false,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
   },
   -- Floating clients.
   { rule_any = {
        instance = {
           "DTA",  -- Firefox addon DownThemAll.
           "copyq",  -- Includes session name in class.
        },
        class = {
           "Arandr",
           "Gpick",
           "Kruler",
           "MessageWin",  -- kalarm.
           "Sxiv",
           "Wpa_gui",
           "pinentry",
           "veromix",
           "xtightvncviewer"},

        name = {
           "Event Tester",  -- xev.
        },
        role = {
           "AlarmWindow",  -- Thunderbird's calendar.
           "pop-up",       -- e.g. Developer Tools.
        }
   }, properties = { floating = true }},

   -- Add titlebars to normal clients and dialogs
   { rule_any = {type = { "dialog" }},
     except_any = {role = { "notify_dialog" }},
     properties = { titlebars_enabled = true }
   },
   -- Custom
   { rule = { class = "MPlayer" },
     properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "Gimp-2.8" },
     properties = { tag = "6", floating = true } },
   { rule = { instance = "owncloud" },
     properties = { floating = true } },
   { rule_any = { class = {"URxvt", ".*ermina.*"} },
     properties = { tag = "2", size_hints_honor = false } },
   { rule = { class = "Emacs" },
     properties = { tag = "3", switchtotag = true, size_hints_honor = false } },
   { rule = { instance = "Ranger" },
     properties = { tag = "6", switchtotag = true, size_hints_honor = false } },
   { rule_any = { role = {"browser"}, class = { "Epiphany" }},
     properties = { tag = "4" } },
   {rule = {instance = "Pidgin"},
    properties = { tag = "5", size_hints_honor = false, floating = true }},
   {rule = {class = "Pidgin", role = "conversation"},
    properties = {width = 1000, height = 670, x = 320, y = 55}},
   -- {rule = {class = "Pidgin", role = "accounts"},
   --  properties = {width = 500, height = 500, x = 0, y = 0}},
   {rule = {class = "Pidgin", role = "buddy_list"},
    properties = {width = 300, height = 670, x = 10, y = 55},
    callback   = awful.client.setslave}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
   "manage", function (c)
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      -- if not awesome.startup then awful.client.setslave(c) end

      if awesome.startup and
         not c.size_hints.user_position
      and not c.size_hints.program_position then
         -- Prevent clients from being unreachable after screen count changes.
         awful.placement.no_offscreen(c)
      end

      -- Awesome 3.x
      -- -- Enable sloppy focus
      -- c:connect_signal("mouse::enter", function(c)
      --                     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      --                     and awful.client.focus.filter(c) then
      --                        client.focus = c
      --                     end
      -- end)

      -- if not startup then
      --    -- Set the windows at the slave,
      --    -- i.e. put it at the end of others instead of setting it master.
      --    -- awful.client.setslave(c)

      --    -- Put windows in a smart way, only if they does not set an initial position.
      --    if not c.size_hints.user_position and not c.size_hints.program_position then
      --       awful.placement.no_overlap(c)
      --       awful.placement.no_offscreen(c)
      --    end
      -- end

      -- local titlebars_enabled = false
      -- if titlebars_enabled then
      --    titlebar_add(c)
      -- end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
   "request::titlebars", function(c)
      -- buttons for the titlebar
      local buttons = awful.util.table.join(
         awful.button({ }, 1, function()
               client.focus = c
               c:raise()
               awful.mouse.client.move(c)
         end),
         awful.button({ }, 3, function()
               client.focus = c
               c:raise()
               awful.mouse.client.resize(c)
         end)
      )

      awful.titlebar(c, {size = 16}):setup
      {
         layout = wibox.layout.align.horizontal,
         { -- Left
            -- awful.titlebar.widget.iconwidget(c),
            -- buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
         },
         { -- Middle
            { -- Title
               align  = "center",
               widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
         },
         { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
      }}
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
   "mouse::enter", function(c)
      if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
         client.focus = c
      end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autorun apps
-- awful.spawn.with_shell("pgrep udiskie || udiskie --smart-tray --notify", false)
-- awful.spawn.with_shell("pgrep kupfer || kupfer --no-splash", false)
-- awful.spawn.with_shell("xrandr --setprovideroffloadsink nouveau Intel", false)
-- awful.spawn.with_shell("pgrep owncloud || owncloud", false)
-- awful.spawn.with_shell("pgrep clipit || clipit", false)
-- awful.spawn.with_shell("pgrep emacs || emacs --daemon --no-splash", false)
-- awful.spawn.with_shell("pgrep urxvtd || urxvtd -q -o", false)
-- awful.spawn.with_shell("light-locker", false)
-- awful.spawn.with_shell("pgrep xss-lock || xss-lock -- light-locker-command --lock &", false)
-- awful.spawn.with_shell("pgrep redshift || redshift", false)
-- awful.spawn.with_shell("pgrep xautolock || xautolock -detectsleep -notify 300 -notifier 'xset dpms force off' -time 10 -locker 'light-locker-command -l' -killtime 30 -killer 'systemctl suspend'", false)
-- }}}
