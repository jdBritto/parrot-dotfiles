#!/bin/sh
# Máquina objetivo (la fijan settarget o Super+Shift+V).
. "$HOME/.config/bspwm/scripts/red-lib.sh"
F="$HOME/.config/bin/target"
read -r ip_address machine_name 2>/dev/null <"$F"
if [ -n "$ip_address" ]; then
    echo "%{F#E5534B}󰓾%{F-} %{F$TEXTO}$ip_address%{F-} %{F$TENUE}·%{F-} ${machine_name:-target}"
else
    echo "%{F#E5534B}󰓾%{F-} %{F$TENUE}sin objetivo%{F-}"
fi
