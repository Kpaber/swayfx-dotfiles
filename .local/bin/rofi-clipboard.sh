#!/usr/bin/bash
cliphist list | rofi -dmenu -location 2 -p 'Буфер обмена' | cliphist decode | wl-copy
