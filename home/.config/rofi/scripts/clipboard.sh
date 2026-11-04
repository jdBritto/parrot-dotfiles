#!/usr/bin/env bash
# Historial de portapapeles (copyq) en rofi, con el tema polybar-dark.
# Enter/clic sobre un elemento lo vuelve a copiar al portapapeles.
export DISPLAY="${DISPLAY:-:0}"
THEME="$HOME/.config/rofi/themes/polybar-dark.rasi"

command -v copyq >/dev/null || { rofi -e "copyq no está instalado:  sudo apt install copyq"; exit 1; }
# arranca el daemon si aún no corre
copyq eval 'true' >/dev/null 2>&1 || { setsid copyq >/dev/null 2>&1 & sleep 0.5; }

mapfile -t rows < <(copyq eval -- '
var n = Math.min(size(), 30);
for (var i = 0; i < n; ++i) {
    var t = str(read(i)).replace(/\s+/g, " ").trim();
    if (t.length === 0) continue;
    if (t.length > 90) t = t.substr(0, 90) + "…";
    print(i + "\t" + t + "\n");
}' 2>/dev/null)

[ "${#rows[@]}" -eq 0 ] && { rofi -e "Portapapeles vacío"; exit 0; }

sel=$(printf '%s\n' "${rows[@]}" | cut -f2- | \
      rofi -dmenu -i -p "  " -format i -theme "$THEME") || exit 0
[ -z "$sel" ] && exit 0
idx=${rows[$sel]%%$'\t'*}
copyq select "$idx" >/dev/null 2>&1
