#!/bin/bash
# Barra de escritorios estilo Pac-Man para bspwm.
# Pac-Man (ᗧ) marca el escritorio actual; los fantasmas (ᗣ) son los escritorios
# por delante y los puntos tenues (·) los que ya "se comió" (escritorios pasados).
# Se actualiza al instante al cambiar de escritorio (bspc subscribe).
#
# Los glyphs solo los dibuja FreeSans, por eso se envuelven en %{T9}...%{T-}
# (font-8 de la barra workspaces_bar). Los clics cambian de escritorio.

FONT="%{T9}"; FONT_END="%{T-}"      # FreeSans tamaño normal (punto · comido)
PAC_FONT="%{T11}"                   # FreeSans grande (glyph Pac-Man ᗧ)
EMOJI="%{T10}"; EMOJI_END="%{T-}"   # Noto Color Emoji (fantasma 👻)
PAC="ᗧ"
DOT="·"

PAC_COLOR="#FFEB3B"                                   # amarillo Pac-Man
DOT_COLOR="#5a6b7b"                                   # punto comido (tenue)
GHOST_COLORS=("#FF0000" "#FFB8FF" "#00FFFF" "#FFB852") # Blinky/Pinky/Inky/Clyde (colores reales)

GHOST="ᗣ"                           # fantasma glyph (FreeSans, escala y se colorea)
GHOST_FONT="%{T9}"                  # FreeSans tamaño normal (mismo que el punto)

# Estilo del fantasma: "glyph" = ᗣ vectorial coloreable (se integra bien y escala).
#                      "emoji" = 👻 a color, PERO Noto Color Emoji ignora el tamaño
#                                y polybar lo rasteriza demasiado grande. No recomendado.
GHOST_MODE="glyph"

render() {
    local desktops focused name line="" reached="" gi=0 col ghost
    mapfile -t desktops < <(bspc query -D --names -m focused)
    focused=$(bspc query -D -d focused --names)
    for name in "${desktops[@]}"; do
        if [ "$name" = "$focused" ]; then
            line+="%{A1:bspc desktop -f ${name}:}${PAC_FONT}%{F${PAC_COLOR}}${PAC}%{F-}${FONT_END}%{A} "
            reached=1
        elif [ -z "$reached" ]; then
            line+="%{A1:bspc desktop -f ${name}:}${FONT}%{F${DOT_COLOR}}${DOT}%{F-}${FONT_END}%{A} "
        else
            if [ "$GHOST_MODE" = "emoji" ]; then
                ghost="${EMOJI}👻${EMOJI_END}"
            else
                col="${GHOST_COLORS[$((gi % ${#GHOST_COLORS[@]}))]}"
                ghost="${GHOST_FONT}%{F${col}}${GHOST}%{F-}${FONT_END}"
                gi=$((gi + 1))
            fi
            line+="%{A1:bspc desktop -f ${name}:}${ghost}%{A} "
        fi
    done
    echo "${line% }"
}

render
bspc subscribe desktop_focus desktop_add desktop_remove node_add node_remove node_transfer node_state | while read -r _; do
    render
done
