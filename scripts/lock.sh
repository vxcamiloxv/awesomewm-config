#!/usr/bin/env bash

primary_screen=($(xrandr | grep -w connected | sed 's/primary //' | awk -F'[ +]' '{print $1,$3,$4}' | head -n 1))
sflock -xshift $((${primary_screen[2]} / 2))
