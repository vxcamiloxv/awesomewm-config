local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local helpers = require("widgets/helpers")
math = require("math")
string = require("string")

local Brightness = { mt = {}, wmt = {} }
Brightness.wmt.__index = Brightness
Brightness.__index = Brightness

config = awful.util.getdir("config")

local function run(command)
   local prog = io.popen(command)
   local result = prog:read('*all')
   prog:close()
   return result
end

function Brightness:new(args)
   local obj = setmetatable({}, self)

   obj.step = args.step or 5
   obj.cmd = args.cmd or "xbacklight"
   obj.incVal = args.inc or "-inc"
   obj.decVal = args.dec or "-dec"
   obj.setVal = args.set or "-set"
   obj.getVal = args.get or "-get"

   -- Create imagebox widget
   obj._icon = wibox.widget.imagebox()
   -- Change the draw method so icons can be drawn smaller
   --helpers:set_draw_method(obj.icon)
   -- icon raw path
   obj.iconpath = config.."/theme/icons/brightness-symbolic.svg"
   obj._icon:set_image(obj.iconpath)
   obj.icon = helpers:set_draw_method(obj._icon)

   -- Add a popup
   obj.popup = nil
   obj.brightness = nil

   helpers:listen(obj, 60)

   --  Listen if signal was found
   obj._icon:connect_signal("mouse::enter", function() obj:popupShow() end)
   obj._icon:connect_signal("mouse::leave", function() obj:popupHide() end)


   obj:update()

   return obj
end

function Brightness:tooltipText()
   return math.floor(self:get()).."% Brightness"
end

function Brightness:update(status)
   local brightness = math.floor(self:get())
   local iconpath = config.."/theme/icons/status/brightness"

   if(brightness < 5) then
      iconpath = iconpath .. "-none"

   elseif(brightness < 10) then
      iconpath = iconpath .. "-verylow"

   elseif(brightness < 25) then
      iconpath = iconpath .. "-low"

   elseif(brightness < 75) then
      iconpath = iconpath .. "-medium"

   elseif(brightness < 90) then
      iconpath = iconpath .. "-high"

   else
      iconpath = iconpath .. "-full"

   end

   self.iconpath = iconpath .. "-symbolic.svg"

   if self.brightness ~= brightness and self.brightness ~= nil then
      self:popupShow(1)
   end

   self._icon:set_image(self.iconpath)
   self.icon = helpers:set_draw_method(self._icon)

   self.brightness = brightness
end

function Brightness:updateDelay()
   local timer = timer({timeout = time or 0})

   timer:connect_signal("timeout", function()
                           self:update({})
                           timer:stop()
   end)
   timer:start()
end

function Brightness:up()
   run(self.cmd.." "..self.incVal.." "..self.step)
   self:updateDelay(0.1)
end

function Brightness:down()
   run(self.cmd.." "..self.decVal.." "..self.step)
   self:updateDelay(0.1)
end

function Brightness:get()
   return run(self.cmd.." "..self.getVal)
end

function Brightness:set(val)
   run(self.cmd.." "..self.setVal.." "..val)
end

function Brightness:popupShow(timeout)
   local icon = self.iconpath
   local tooltipText = self:tooltipText()
   self:popupHide()
   self.popup = naughty.notify({ icon = icon,
                                 icon_size = 16,
                                 text =  tooltipText,
                                 timeout = timeout, hover_timeout = 0.5,
                                 screen = mouse.screen,
   })
end

function Brightness:popupHide()
   if self.popup ~= nil then
      naughty.destroy(self.popup)
      self.popup = nil
   end
end

function Brightness.mt:__call(...)
   return Brightness.new(...)
end

return Brightness:new({})
