#!/bin/sh
# IP de la VPN (tun*/wg*/tap*). Clic izquierdo = copiar.
. "$HOME/.config/bspwm/scripts/red-lib.sh"
dev=$(iface_vpn)
ipaddr=$(ip_de "$dev")
if [ -n "$ipaddr" ]; then
    echo "%{F#1BBF3E}󰖂%{F-} %{F$TEXTO}$ipaddr%{F-}"
else
    echo "%{F$TENUE}󰖂 sin VPN%{F-}"
fi
[ "$1" = copiar ] && [ -n "$ipaddr" ] && printf '%s' "$ipaddr" | xclip -sel clip && notify-send -t 1500 "󰖂 IP VPN copiada" "$ipaddr"
exit 0
