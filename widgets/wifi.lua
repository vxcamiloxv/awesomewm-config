--[[

   Awesome WM Wifi Widget
   Distopico Vegan <distopico [at] riseup [dot] net>
   Licensed under GPL3

   Original from: https://github.com/mrzapp/awesomerc

--]]

local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local helpers = require("widgets/helpers")

local config = awful.util.getdir("config")
local widget = {}
local popup = nil
local adapter = ""
local iconpath = ""
local networktext = "--"


-- {{{ Define sub-widgets
widget.text = wibox.widget.textbox()
widget._icon = wibox.widget.imagebox()

-- {{{ Define interactive behavior
widget._icon:buttons(awful.util.table.join(
                        awful.button({ }, 1, function () awful.util.spawn("gnome-control-center network") end)
))
-- }}}

-- {{{ Check adapter method
function widget:check()
   -- Test adapter
   adapter = "wlan0"
   self.haswifi = helpers:test("iwconfig " .. adapter)

   -- Try another adapter name
   if not self.haswifi then
      adapter = "wlp8s0"
      self.haswifi = helpers:test("iwconfig " .. adapter)
   end
end
-- }}}

-- {{{ Update method
function widget:update()
   local quality = 0
   local connected = ""
   local rate = ""
   spacer = " "

   if not self.haswifi then
      -- Check adapter
      self:check()
   end

   -- definitely has not
   if not self.haswifi then
      return
   end

   if not helpers:test("nmcli") then
      local wifi = helpers:run("iwconfig " .. adapter)
      local wifiMin, wifiMax = string.match(wifi, "(%d?%d)/(%d?%d)")

      connected = string.match(wifi, "ESSID:\"(.*)\"")
      wifiMin = tonumber(wifiMin) or 0
      wifiMax = tonumber(wifiMax) or 70
      quality = math.floor(wifiMin / wifiMax * 100)
   else
      local wifi = helpers:run("nmcli -t device wifi")
      local data = string.match(wifi, "*:(.*)")
      local values = {}
      local i = 0;

      if data ~= nil then
         for val in string.gmatch(data, "([^:]+)") do
            values[i] = val
            i = i + 1
         end

         if tonumber(values[4]) ~= nil then
            connected = values[0]
            quality = math.floor(values[4] or 0)
            rate = " | " .. values[3] .. " | " .. values[5]
         end
      end
   end

   networktext = quality .. "%"

   if quality <= 0 then
      networktext = " no connected"
   elseif connected then
      networktext = networktext .. " | " .. connected .. rate
   end

   self.text:set_markup(networktext)

   iconpath = config.."/theme/icons/status/network-wireless-signal"

   if quality <= 0 then
       iconpath = iconpath .. "-none"

    elseif quality < 25 then
       iconpath = iconpath .. "-weak"

    elseif quality < 50 then
       iconpath = iconpath .. "-ok"

    elseif quality < 75 then
       iconpath = iconpath .. "-good"

    else
       iconpath = iconpath .. "-excellent"

    end

    iconpath = iconpath .. "-symbolic.svg"

    self._icon:set_image(iconpath)
    self.icon = helpers:set_draw_method(self._icon)
end

function widget:show()
   popup = naughty.notify({ icon = iconpath,
                            icon_size = 16,
                            text = networktext,
                            timeout = 0, hover_timeout = 0.5,
                            screen = mouse.screen,
                            ignore_suspend = true
   })
end

function widget:hide()
   if popup ~= nil then
      naughty.destroy(popup)
      popup = nil
   end
end
-- }}}

-- {{{ Listen if signal was found
helpers:listen(widget, 30)

widget._icon:connect_signal("mouse::enter", function() widget:show() end)
widget._icon:connect_signal("mouse::leave", function() widget:hide() end)
-- }}}

return widget;
