#!/usr/bin/env bash
source "`dirname $0`/scripts/run.sh"
primary_screen=($(xrandr | grep -w connected | sed 's/primary //' | awk -F'[ +]' '{print $1,$3,$4}' | head -n 1))

# General config
# ---------------
# Keyboard layout
setxkbmap latam

# Touchpad config
xinput --set-prop 14 "libinput Natural Scrolling Enabled" 1
xinput --set-prop 14 "libinput Click Method Enabled" {1 1}
xinput --set-prop 14 "libinput Tapping Enabled" 1

# Composition
run compton -l -4 -t -4 -r 3 -o 0.3 -C -b --no-fading-openclose

# Autorun apps
# --------------
run udiskie --smart-tray --notify
run kupfer --no-splash
run owncloud
#run clipit
run emacs --daemon --no-splash
run urxvtd -q -o
run parcellite
#pgrep light-locker || light-locker &
run redshift-gtk
run xss-lock -- sflock -xshift $((${primary_screen[2]} / 2)) &
#pgrep xautolock || xautolock -detectsleep -notify 300 -notifier 'xset dpms force off' -time 10 -locker 'light-locker-command -l' -killtime 30 -killer 'systemctl suspend$

# Enable layoutscreen
#[ -f ~/.scripts/screenlayout ] && ~/.scripts/screenlayout &

