# Funciones comunes para los scripts de la polybar (se cargan con ".").
# Colores del fondo actual (los genera matugen); valores por defecto si faltan.
ACENTO="#44ABFF"; TEXTO="#E6EDF3"; TENUE="#6E7681"
[ -r "$HOME/.config/bspwm/colores.sh" ] && . "$HOME/.config/bspwm/colores.sh"

# Interfaz de la ruta por defecto (enp1s0, eth0, wlan0...), sin contar VPNs.
iface_principal() {
    ip -4 route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}'
}
# Primera interfaz VPN activa (tun0, tun1, wg0, ...).
iface_vpn() {
    ip -4 -br addr show 2>/dev/null | awk '$1 ~ /^(tun|wg|tap)[0-9]+/ && $3 != "" {print $1; exit}'
}
# IPv4 de una interfaz, sin la máscara.
ip_de() {
    ip -4 -br addr show "$1" 2>/dev/null | awk '{split($3,a,"/"); print a[1]}'
}
