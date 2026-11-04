#!/bin/sh
# IP local de la interfaz principal. Clic izquierdo = copiar (ver current.ini).
. "$HOME/.config/bspwm/scripts/red-lib.sh"
dev=$(iface_principal)
ipaddr=$(ip_de "$dev")
if [ -n "$ipaddr" ]; then
    echo "%{F$ACENTO}󰈀%{F-} %{F$TEXTO}$ipaddr%{F-}"
else
    echo "%{F$TENUE}󰈂 sin red%{F-}"
fi
[ "$1" = copiar ] && [ -n "$ipaddr" ] && printf '%s' "$ipaddr" | xclip -sel clip && notify-send -t 1500 "󰈀 IP local copiada" "$ipaddr"
exit 0
