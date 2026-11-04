#!/bin/bash
# Lanza el diseño de barras flotantes de pentesting definido en current.ini.
# (Para volver a la barra única de ParrotOS: usar launch.sh.parrot.bak)

CFG="$HOME/.config/polybar/current.ini"

# Cierra cualquier instancia previa y espera a que terminen
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.5; done

# Lanza cada barra flotante definida en current.ini
# (bar/main es solo la plantilla base de la que heredan las demás; no se lanza)
for bar in workspaces_bar primary target_to_hack ethernet_bar vpn_bar secondary log top; do
    polybar -q -r -c "$CFG" "$bar" &
done
