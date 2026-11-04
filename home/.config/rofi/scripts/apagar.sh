#!/usr/bin/env bash
# Menú de apagado para BSPWM (Super + Shift + Escape o el botón de la polybar).
TEMA="$HOME/.config/rofi/themes/moderno.rasi"
up=$(uptime -p | sed 's/^up //')

bloquear="  Bloquear"
suspender="󰒲  Suspender"
salir="󰍃  Cerrar sesión"
reiniciar="  Reiniciar"
apagar="  Apagar"

sel=$(printf '%s\n' "$bloquear" "$suspender" "$salir" "$reiniciar" "$apagar" |
      rofi -dmenu -i -p "  Sistema" -mesg "Encendido: $up" -theme "$TEMA" \
           -theme-str 'window { width: 380px; } listview { lines: 5; } mainbox { children: [ inputbar, message, listview ]; } element-icon { enabled: false; }') || exit 0

confirmar() { [ "$(printf 'No\nSí' | rofi -dmenu -p "¿$1?" -theme "$TEMA" \
              -theme-str 'window { width: 300px; } listview { lines: 2; } mainbox { children: [ inputbar, listview ]; }')" = "Sí" ]; }

case "$sel" in
    "$bloquear")  ~/.config/xsecurelock/lock.sh ;;
    "$suspender") ~/.config/xsecurelock/lock.sh & sleep 1; systemctl suspend ;;
    "$salir")     confirmar "Cerrar sesión" && bspc quit ;;
    "$reiniciar") confirmar "Reiniciar" && systemctl reboot ;;
    "$apagar")    confirmar "Apagar" && systemctl poweroff ;;
esac
