#!/bin/bash

options="⏻ Выключение\n󰑓 Перезагрузка\n Ожидание\n Гибернация\n Выход"
#options="⏻ \n󰑓 \n \n \n "

chosen=$(echo -e "$options" | rofi -dmenu -location 3 -xoffset -36 -yoffset 44 -theme ~/.config/rofi/themes/power.rasi -p "")

case "$chosen" in
    *Выключение) systemctl poweroff ;;
    *Перезагрузка) systemctl reboot ;;
    *Ожидание) systemctl suspend ;;
	*Гибернация) systemctl hibernate;;
    *Выход) swaymsg exit ;;
esac
