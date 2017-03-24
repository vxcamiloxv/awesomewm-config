local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local helpers = require("widgets/helpers")

local widget = {}

local popup = nil
local iconpath = ""
local qualitytext = "--"

-- {{{ Define the adapter
local adapter = "wlan0"

-- Test adapter
widget.haswifi = helpers:test("iwconfig " .. adapter)

-- Try another adapter name
if not widget.haswifi then
   adapter = "wlp8s0"
   widget.haswifi = helpers:test("ifconfig " .. adapter)
end
-- }}}

-- {{{ Define subwidgets
widget.text = wibox.widget.textbox()
widget._icon = wibox.widget.imagebox()

-- Change the draw method so icons can be drawn smaller
-- helpers:set_draw_method(widget._icon)
-- }}}

-- {{{ Define interactive behaviour
widget._icon:buttons(awful.util.table.join(
                        awful.button({ }, 1, function () awful.util.spawn("gnome-control-center network") end)
))
-- }}}

-- {{{ Update method
function widget:update()
    spacer = " "

    local f = io.popen("sudo iwconfig " .. adapter)
    local wifi = f:read("*all")
    local connected = string.match(wifi, "ESSID:\"(.*)\"")
    local wifiMin, wifiMax = string.match(wifi, "(%d?%d)/(%d?%d)")

    wifiMin = tonumber(wifiMin) or 0
    wifiMax = tonumber(wifiMax) or 70

    local quality = math.floor(wifiMin / wifiMax * 100)
    qualitytext = quality .. "%"

    if connected then
       qualitytext = qualitytext .. " (" .. connected .. ")"
    end

    widget.text:set_markup(qualitytext)

    iconpath = "/usr/share/icons/gnome/scalable/status/network-wireless-signal"

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

    widget._icon:set_image(iconpath)
    widget.icon = helpers:set_draw_method(widget._icon)

    f:close()
end

function widget:show()
   popup = naughty.notify({ icon = iconpath,
                            icon_size = 16,
                            text = qualitytext,
                            timeout = 0, hover_timeout = 0.5,
                            screen = mouse.screen,
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
if widget.haswifi then
   helpers:listen(widget, 30)
end

widget._icon:connect_signal("mouse::enter", function() widget:show() end)
widget._icon:connect_signal("mouse::leave", function() widget:hide() end)
-- }}}

return widget;
