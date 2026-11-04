#!/bin/bash
# Barra de escritorios estilo Pac-Man para bspwm (posición + contenido).
#   ᗧ Pac-Man            = escritorio actual
#   Por delante:  ᗣ a color = con ventanas   ·  ᗣ gris = vacío
#   Por detrás:   ● pellet  = con ventanas   ·  · punto tenue = vacío
# Copia de ~/.config/bspwm/scripts/pacman_workspaces.sh (el original no se tocó).
# Los glyphs los dibuja FreeSans: %{T9} normal, %{T11} grande. Clic = cambiar.

FONT="%{T9}"; FONT_END="%{T-}"
PAC_FONT="%{T11}"
PAC="ᗧ"; GHOST="ᗣ"; DOT="·"; PELLET="●"

PAC_COLOR="#FFEB3B"
DOT_COLOR="#5a6b7b"        # punto comido / fantasma vacío (tenue)
PELLET_COLOR="#FFB8AE"     # power pellet (color del juego)
GHOST_COLORS=("#FF0000" "#FFB8FF" "#00FFFF" "#FFB852") # Blinky/Pinky/Inky/Clyde

render() {
    local desktops occupied focused name line="" reached="" gi=0 col glyph
    mapfile -t desktops < <(bspc query -D --names -m focused)
    occupied=" $(bspc query -D -d .occupied --names -m focused | tr '\n' ' ') "
    focused=$(bspc query -D -d focused --names)
    for name in "${desktops[@]}"; do
        if [ "$name" = "$focused" ]; then
            line+="%{A1:bspc desktop -f ${name}:}${PAC_FONT}%{F${PAC_COLOR}}${PAC}%{F-}${FONT_END}%{A} "
            reached=1
            continue
        fi
        if [ -z "$reached" ]; then
            # detrás de Pac-Man
            if [[ "$occupied" == *" $name "* ]]; then
                glyph="%{F${PELLET_COLOR}}${PELLET}%{F-}"
            else
                glyph="%{F${DOT_COLOR}}${DOT}%{F-}"
            fi
        else
            # delante de Pac-Man
            if [[ "$occupied" == *" $name "* ]]; then
                col="${GHOST_COLORS[$((gi % ${#GHOST_COLORS[@]}))]}"
                gi=$((gi + 1))
            else
                col="$DOT_COLOR"
            fi
            glyph="%{F${col}}${GHOST}%{F-}"
        fi
        line+="%{A1:bspc desktop -f ${name}:}${FONT}${glyph}${FONT_END}%{A} "
    done
    echo "${line% }"
}

render
bspc subscribe desktop_focus desktop_add desktop_remove node_add node_remove node_transfer node_state | while read -r _; do
    render
done
