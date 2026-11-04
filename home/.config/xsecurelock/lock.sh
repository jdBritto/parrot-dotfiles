#!/bin/sh
# Pantalla de bloqueo: fondo Matrix + asteriscos que crecen al teclear.
export XSECURELOCK_SAVER="$HOME/.config/xsecurelock/saver-matrix"
export XSECURELOCK_FONT="Hack Nerd Font Mono"
export XSECURELOCK_PASSWORD_PROMPT="asterisks"   # prueba "disco" para dots de colores
export XSECURELOCK_SHOW_USERNAME=1
export XSECURELOCK_SHOW_HOSTNAME=0
export XSECURELOCK_SHOW_DATETIME=1
export XSECURELOCK_DATETIME_FORMAT="%H:%M  ·  %a %d %b"
export XSECURELOCK_AUTH_BACKGROUND_COLOR="#0b0e14"
export XSECURELOCK_AUTH_FOREGROUND_COLOR="#2BE84F"
export XSECURELOCK_AUTH_WARNING_COLOR="#E5534B"
export XSECURELOCK_CURSOR_COLOR="#44ABFF"
export XSECURELOCK_SAVER_RESET_ON_AUTH_CLOSE=1
export XSECURELOCK_BLANK_TIMEOUT=-1
exec xsecurelock
