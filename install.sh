#!/bin/bash
# Instala estilos de escritorio para Parrot OS 7: Niri moderno (con
# DankMaterialShell), Windows (labwc), Hyprland Parrot y macOS (KDE Plasma con
# identidad Parrot).
# (Tambien sirve en Debian 13 "trixie", que es la base de Parrot 7.)
# Al empezar muestra un menu para elegir estilos y extras (flechas y Espacio),
# y con cual de ellos arranca el equipo.
#
# Uso:  ./install.sh         (pregunta todo)
#       ./install.sh --si    (sin preguntas: lo recomendado, arranca en Niri)
#
# El escritorio original de Parrot (KDE, MATE...) no se toca: sigue disponible
# en la pantalla de inicio y puedes volver con: sesion parrot
# Es seguro ejecutarlo mas de una vez. Antes de sobrescribir guarda una copia
# de tus archivos en ~/.config-respaldo-<fecha>.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESPALDO="$HOME/.config-respaldo-$(date +%Y%m%d-%H%M%S)"
OBS=https://download.opensuse.org/repositories/home:/AvengeMedia

# apt sin preguntas (por ejemplo, al instalar SDDM no pregunta cual usar).
apt_() { sudo DEBIAN_FRONTEND=noninteractive apt-get "$@"; }
verde() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
AVISOS=()
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; AVISOS+=("$*"); }
error() { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- opciones
PREGUNTAR=true
for arg in "$@"; do
  case "$arg" in
    --si)      PREGUNTAR=false ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         error "Opcion desconocida: $arg (mira: ./install.sh --help)" ;;
  esac
done
[[ -t 0 ]] || PREGUNTAR=false

# ---------------------------------------------------------------- comprobaciones
[[ $EUID -ne 0 ]] || error "No lo ejecutes con sudo; ejecutalo como tu usuario normal."
command -v apt-get >/dev/null || error "Este script es para Parrot OS / Debian."
. /etc/os-release
case "$ID:${VERSION_CODENAME:-}" in
  parrot:echo)    BACKPORTS=echo-backports ;;
  debian:trixie)  BACKPORTS=trixie-backports ;;
  *) error "Sistema no soportado: ${PRETTY_NAME:-desconocido}. Hace falta Parrot 7 (echo) o Debian 13 (trixie)." ;;
esac
ARQ=$(dpkg --print-architecture)
[[ $ARQ == amd64 || $ARQ == arm64 ]] || error "Arquitectura no soportada: $ARQ"

ES_VMWARE=false
[[ $(systemd-detect-virt 2>/dev/null || true) == vmware ]] && ES_VMWARE=true
TIENE_PANTALLA_INICIO=false
systemctl is-enabled display-manager.service &>/dev/null && TIENE_PANTALLA_INICIO=true

echo "Sistema: $PRETTY_NAME ($ARQ)"
echo "Maquina virtual VMware: $ES_VMWARE"

# ---------------------------------------------------------------- logo
logo() {
  local colores=(51 45 39 63 99 135) i=0 linea
  while IFS= read -r linea; do
    printf '\033[1;38;5;%sm%s\033[0m\n' "${colores[i % ${#colores[@]}]}" "$linea"
    i=$((i + 1))
  done <<'LOGO'

  ███╗   ██╗██╗██████╗ ██╗       ██████╗ ███╗   ███╗███████╗
  ████╗  ██║██║██╔══██╗██║       ██╔══██╗████╗ ████║██╔════╝
  ██╔██╗ ██║██║██████╔╝██║  ━╋━  ██║  ██║██╔████╔██║███████╗
  ██║╚██╗██║██║██╔══██╗██║       ██║  ██║██║╚██╔╝██║╚════██║
  ██║ ╚████║██║██║  ██║██║       ██████╔╝██║ ╚═╝ ██║███████║
  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝╚═╝       ╚═════╝ ╚═╝     ╚═╝╚══════╝
LOGO
  printf '\033[2m  Estilos de escritorio (Niri, Windows, Hyprland, macOS) para %s\033[0m\n\n' "${PRETTY_NAME:-Parrot OS 7}"
}

# ---------------------------------------------------------------- que instalar
# Dos grupos: estilos de escritorio (se pueden instalar varios; cada uno es una
# sesion de la pantalla de inicio) y extras.
IDS=()
declare -A NOMBRE DESC MARCA GRUPO
agregar() { IDS+=("$1"); GRUPO[$1]=$2; NOMBRE[$1]=$3; DESC[$1]=$4; MARCA[$1]=$5; }

agregar niri estilo "Niri moderno" "Niri con DankMaterialShell: ventanas en columnas que se desplazan, barra y menus de DMS. Colores que siguen al fondo." si
agregar futurista estilo "  ↳ Modo futurista (para Niri)" "Animaciones holograma, borde neon y cristal; los colores siguen al fondo. Se activa y desactiva con: futurista on / off" si
agregar windows estilo "Windows (labwc)" "Ventanas flotantes con minimizar/maximizar/cerrar y atajos de Windows (Win+E, Alt+F4, Win+flechas), con la barra de DankMaterialShell." si
agregar hyprland estilo "Hyprland Parrot" "Hyprland con 7 temas que se cambian al instante (Parrot, HackTheBox, Vaporwave...), barra, menus faciles (Super + A), columnas como Niri y modo rendimiento para equipos modestos." no
command -v plasmashell >/dev/null &&
  agregar macos estilo "macOS (KDE Plasma)" "Barra arriba con el menu de la app, dock abajo, botones de Mac y Spotlight (Meta+Espacio), con los iconos, el verde, el logo y el fondo de Parrot. Claro de dia y oscuro de noche, y pantalla de inicio estilo macOS." no
$TIENE_PANTALLA_INICIO || agregar pantalla-inicio extra "Pantalla de inicio (SDDM)" "Este equipo no tiene pantalla de inicio de sesion; instala SDDM." si
agregar terminales extra "Terminales" "Ghostty, Kitty, Alacritty y Foot con su configuracion y la fuente JetBrainsMono Nerd." si
agregar apps extra "Apps" "Firefox, nano y cava." si
agregar tienda extra "Tienda de apps (Bazaar)" "Flatpak con Flathub y la tienda Bazaar; abre los .flatpak con doble clic." no
agregar herramientas extra "Herramientas de desarrollo" "claude, codex, gh, node y opencode (con mise)." si
[[ $ARQ == amd64 ]] && agregar dictado extra "Dictado por voz" "voxtype: dictas con Super + Ctrl + X (en Niri)." si
agregar fondos extra "Galeria de fondos" "Enlaza los fondos que trae Parrot en ~/Pictures/Fondos." si
$ES_VMWARE && agregar vmware extra "Ajustes para VMware" "Resolucion, renderizado y herramientas de la maquina virtual." si

quiere() { [[ ${MARCA[$1]:-no} == si ]]; }
cambiar() { if quiere "$1"; then MARCA[$1]=no; else MARCA[$1]=si; fi; }
# Niri y Windows usan DankMaterialShell; macOS no lo necesita.
usa_dms() { quiere niri || quiere windows; }
estilos_elegidos() { local id; for id in niri windows hyprland macos; do quiere "$id" && echo "$id"; done; return 0; }
declare -A TITULO_GRUPO=([estilo]="ESTILO DEL ESCRITORIO  (puedes elegir varios)" [extra]="EXTRAS")

leer_tecla() {  # deja en TECLA la tecla pulsada; las flechas llegan como Esc + [A / [B
  local resto
  IFS= read -rsn1 TECLA || exit 1
  if [[ $TECLA == $'\e' ]]; then
    IFS= read -rsn2 -t 0.1 resto || true
    TECLA+=$resto
  fi
}

# Menu con flechas: se mueve con arriba/abajo (o j/k), Espacio marca o desmarca.
menu() {
  local actual=0 total=${#IDS[@]} i id marca grupo nota=""
  printf '\033[?25l'                 # ocultar el cursor mientras se elige
  trap 'printf "\033[?25h"' EXIT
  while true; do
    printf '\033[H\033[2J'
    logo
    grupo=""
    for i in "${!IDS[@]}"; do
      id=${IDS[i]}
      if [[ ${GRUPO[$id]} != "$grupo" ]]; then
        grupo=${GRUPO[$id]}
        printf '\n  \033[1m%s\033[0m\n' "${TITULO_GRUPO[$grupo]}"
      fi
      if quiere "$id"; then marca='\033[1;32m[x]\033[0m'; else marca='\033[2m[ ]\033[0m'; fi
      if ((i == actual)); then
        printf '  \033[1;36m❯\033[0m %b \033[1;36m%s\033[0m\n' "$marca" "${NOMBRE[$id]}"
      else
        printf '    %b %s\n' "$marca" "${NOMBRE[$id]}"
      fi
    done
    printf '\n  \033[3m%s\033[0m\n' "${DESC[${IDS[actual]}]}"
    [[ -n $nota ]] && printf '\n  \033[1;33m%s\033[0m\n' "$nota"
    printf '\n  \033[2m↑↓ moverse   Espacio marcar   a todo   n nada   Enter continuar   q salir\033[0m\n'
    nota=""

    leer_tecla
    case $TECLA in
      $'\e[A' | k) actual=$(((actual - 1 + total) % total)) ;;
      $'\e[B' | j) actual=$(((actual + 1) % total)) ;;
      ' ') cambiar "${IDS[actual]}" ;;
      [1-9]) if ((TECLA <= total)); then actual=$((TECLA - 1)); cambiar "${IDS[actual]}"; fi ;;
      a | A) for id in "${IDS[@]}"; do MARCA[$id]=si; done ;;
      n | N) for id in "${IDS[@]}"; do MARCA[$id]=no; done ;;
      '') [[ -n $(estilos_elegidos) ]] && break
          nota="Elige al menos un estilo de escritorio." ;;
      q | Q) printf '\033[H\033[2J'; echo "Cancelado. No se cambio nada."; exit 0 ;;
    esac
  done
  printf '\033[?25h\033[H\033[2J'
  logo
}

# Con que estilo arranca el equipo (solo se pregunta si hay mas de uno).
declare -A NOMBRE_ARRANQUE=([niri]="Niri moderno" [windows]="Windows (labwc)" [hyprland]="Hyprland Parrot" [macos]="macOS (KDE Plasma)")
elegir_arranque() {
  local opciones actual=0 i
  mapfile -t opciones < <(estilos_elegidos)
  ARRANQUE=${opciones[0]}
  ((${#opciones[@]} > 1)) && $PREGUNTAR || return 0
  printf '\033[?25l'
  while true; do
    printf '\033[H\033[2J'
    logo
    printf '  \033[1mCON QUE ESTILO ARRANCA EL EQUIPO\033[0m\n'
    printf '  \033[2mLos demas siguen disponibles en la pantalla de inicio y con el comando "sesion".\033[0m\n\n'
    for i in "${!opciones[@]}"; do
      if ((i == actual)); then
        printf '  \033[1;36m❯ (•) %s\033[0m\n' "${NOMBRE_ARRANQUE[${opciones[i]}]}"
      else
        printf '    ( ) %s\n' "${NOMBRE_ARRANQUE[${opciones[i]}]}"
      fi
    done
    printf '\n  \033[2m↑↓ moverse   Enter elegir   q salir\033[0m\n'
    leer_tecla
    case $TECLA in
      $'\e[A' | k) actual=$(((actual - 1 + ${#opciones[@]}) % ${#opciones[@]})) ;;
      $'\e[B' | j) actual=$(((actual + 1) % ${#opciones[@]})) ;;
      '') ARRANQUE=${opciones[actual]}; break ;;
      q | Q) printf '\033[?25h\033[H\033[2J'; echo "Cancelado. No se cambio nada."; exit 0 ;;
    esac
  done
  printf '\033[?25h\033[H\033[2J'
  logo
}

if $PREGUNTAR; then menu; else logo; fi
quiere niri || MARCA[futurista]=no
elegir_arranque

resumen() { local id; for id in "${IDS[@]}"; do quiere "$id" && printf '%s, ' "${NOMBRE[$id]# *↳ }"; done; return 0; }
LISTA=$(resumen)
echo "Se va a instalar: ${LISTA%, }"
echo "El equipo arrancara con: ${NOMBRE_ARRANQUE[$ARRANQUE]}"
if $PREGUNTAR; then
  read -rp "Continuar? [S/n] " r
  [[ $r =~ ^[nN]$ ]] && { echo "Cancelado. No se cambio nada."; exit 0; }
fi
sudo -v || error "Hace falta tu contrasena de administrador."

# ---------------------------------------------------------------- registro
# Todo lo que se muestra se guarda tambien en un archivo, para poder revisar
# los errores despues aunque la terminal se haya cerrado o se pasaran rapido.
LOG="$HOME/.cache/parrot-dotfiles/install-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$(dirname "$LOG")"
ln -sfn "$LOG" "$HOME/.cache/parrot-dotfiles/ultimo.log"
exec > >(tee -a "$LOG") 2>&1
al_salir() {
  local codigo=$?
  printf '\033[?25h'
  if ((codigo != 0)); then
    printf '\n\033[1;31mLa instalacion se detuvo (codigo %s).\033[0m\n' "$codigo"
    printf 'Revisa el registro: %s\n' "$LOG"
  fi
}
trap al_salir EXIT
trap 'aviso "Fallo la linea $LINENO: $BASH_COMMAND"' ERR
echo "Registro de la instalacion: $LOG"

# ---------------------------------------------------------------- repositorios
verde "Agregando repositorios"
apt_ update
apt_ install -y curl gpg ca-certificates
sudo install -d -m 0755 /etc/apt/keyrings

agregar_repo() { # agregar_repo NOMBRE URL_CLAVE LINEA_DEB
  local nombre=$1 clave=$2 linea=$3
  curl -fsSL "$clave" | sudo gpg --dearmor --yes -o "/etc/apt/keyrings/$nombre.gpg"
  echo "deb [signed-by=/etc/apt/keyrings/$nombre.gpg] $linea" | sudo tee "/etc/apt/sources.list.d/$nombre.list" >/dev/null
}
if usa_dms; then
  agregar_repo duxlabs "$OBS:/danklinux/Debian_13/Release.key" "$OBS:/danklinux/Debian_13/ /"
  agregar_repo avengemedia-dms "$OBS:/dms/Debian_13/Release.key" "$OBS:/dms/Debian_13/ /"
fi
if quiere herramientas; then
  agregar_repo mise https://mise.jdx.dev/gpg-key.pub "https://mise.jdx.dev/deb stable main"
fi

# quickshell (la base de DMS) debe venir de los backports de Parrot/Debian,
# no del repositorio de DankLinux, que esta obsoleto para Debian.
if usa_dms; then
  if [[ $BACKPORTS == trixie-backports ]] && ! grep -rqs "trixie-backports" /etc/apt/sources.list /etc/apt/sources.list.d/; then
    echo "deb http://deb.debian.org/debian trixie-backports main" | sudo tee /etc/apt/sources.list.d/trixie-backports.list >/dev/null
  fi
  if [[ $BACKPORTS == echo-backports ]] && ! grep -rqs "echo-backports" /etc/apt/sources.list /etc/apt/sources.list.d/; then
    echo "deb https://deb.parrot.sh/parrot echo-backports main contrib non-free non-free-firmware" |
      sudo tee /etc/apt/sources.list.d/parrot-backports.list >/dev/null
  fi
  printf 'Package: quickshell\nPin: origin download.opensuse.org\nPin-Priority: -1\n' |
    sudo tee /etc/apt/preferences.d/quickshell-backports >/dev/null
fi

# ---------------------------------------------------------------- paquetes
verde "Instalando paquetes"
apt_ update
if usa_dms; then
  apt_ install -y -t "$BACKPORTS" quickshell || error "No se pudo instalar quickshell desde $BACKPORTS."
fi

leer_lista() { grep -vE '^\s*(#|$)' "$REPO/paquetes/$1.txt"; }
PAQUETES=()
usa_dms && mapfile -t -O 0 PAQUETES < <(leer_lista dms)
for id in "${IDS[@]}"; do
  [[ $id == hyprland ]] && continue   # va aparte, desde backports
  if quiere "$id" && [[ -f $REPO/paquetes/$id.txt ]]; then
    mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(leer_lista "$id")
  fi
done
if ((${#PAQUETES[@]})); then
  echo "Instalando: ${PAQUETES[*]}"
  apt_ install -y "${PAQUETES[@]}" || error "No se pudieron instalar algunos paquetes."
fi

# Hyprland del repositorio principal de Parrot no se puede instalar (pide
# bibliotecas mas nuevas); la de backports si. Los espejos de Parrot a veces
# fallan al descargar, por eso se reintenta.
if quiere hyprland; then
  verde "Instalando Hyprland desde $BACKPORTS"
  mapfile -t HYPR_PAQ < <(leer_lista hyprland)
  ok=false
  for intento in 1 2 3 4; do
    apt_ install -y -t "$BACKPORTS" "${HYPR_PAQ[@]}" && { ok=true; break; }
    echo "Reintentando la descarga ($intento)..."; sleep 3
  done
  $ok || error "No se pudo instalar Hyprland desde $BACKPORTS."
fi

if quiere dictado && ! command -v voxtype >/dev/null; then
  verde "Descargando voxtype (dictado por voz)"
  URL=$(curl -fsSL https://api.github.com/repos/peteonrails/voxtype/releases/latest |
    grep -o 'https://[^"]*_amd64\.deb' | head -n1 || true)
  if [[ -n $URL ]]; then
    TMP=$(mktemp -d)
    curl -fsSLo "$TMP/voxtype.deb" "$URL" &&
      apt_ install -y "$TMP/voxtype.deb" || aviso "No se pudo instalar voxtype."
    rm -rf "$TMP"
  else
    aviso "No encontre la descarga de voxtype; omitido."
  fi
fi

# Lo siguiente solo hace falta para DankMaterialShell (Niri y Windows).
if usa_dms; then
  # Sin el plugin de Wayland para Qt6, DMS se cierra al arrancar y el escritorio
  # queda vacio (solo el cursor). Comprobarlo para no terminar sin avisar.
  QT_PLUGINS=$(dpkg -L qt6-wayland 2>/dev/null | grep -m1 '/platforms/libqwayland' || true)
  [[ -n $QT_PLUGINS ]] || error "Falta el plugin de Wayland de Qt6 (paquete qt6-wayland); DMS no podria abrirse."

  # DMS necesita leer el teclado y otros dispositivos de entrada (grupo input).
  if ! id -nG "$USER" | grep -qw input; then
    sudo usermod -a -G input "$USER" || aviso "No se pudo agregar tu usuario al grupo input."
  fi

  # El paquete dms se activa solo para TODAS las sesiones graficas (tambien KDE).
  # Aqui solo debe arrancar con Niri, que ya lo lanza en su configuracion.
  sudo systemctl --global disable dms.service 2>/dev/null || true
  systemctl --user disable dms.service 2>/dev/null || true
fi

# ---------------------------------------------------------------- archivos
copiar() { # copiar ORIGEN RUTA...: copia esas rutas de ORIGEN a $HOME, respaldando lo que ya exista
  local origen=$1; shift
  local ruta f rel destino
  for ruta in "$@"; do
    [[ -e $origen/$ruta ]] || continue
    while IFS= read -r -d '' f; do
      rel=${f#"$origen"/}
      destino="$HOME/$rel"
      if [[ -e $destino && ! -L $f ]] && ! cmp -s "$f" "$destino"; then
        mkdir -p "$(dirname "$RESPALDO/$rel")"
        cp -a "$destino" "$RESPALDO/$rel"
      fi
      mkdir -p "$(dirname "$destino")"
      [[ -L $f ]] && rm -f "$destino"   # los enlaces se reemplazan tal cual
      cp -a "$f" "$destino"
    done < <(find "$origen/$ruta" \( -type f -o -type l \) -print0)
  done
}

# Si DMS esta en marcha (por ejemplo, al reinstalar desde Niri), se para
# mientras se copian sus archivos; si no, podria sobrescribirlos al cerrarse.
# Se vuelve a abrir al final.
DMS_ESTABA=false
if pgrep -x dms >/dev/null || pgrep -f "qs -p .*dms-shell" >/dev/null; then
  DMS_ESTABA=true
  dms kill >/dev/null 2>&1 || true
fi

verde "Copiando configuracion"
H="$REPO/home"
copiar "$H" .local/bin/sesion
chmod +x "$HOME/.local/bin/sesion"
if usa_dms; then
  copiar "$H" .config/DankMaterialShell .config/matugen .local/bin/undercover
  sed -i "s|/home/jdbritto|$HOME|g" "$HOME/.config/matugen/config.toml"
  chmod +x "$HOME/.local/bin/undercover"
fi
if quiere niri; then
  copiar "$H" .config/niri .local/bin/futurista
  # Niri no entiende $HOME en su configuracion: poner la ruta real.
  sed -i "s|/home/jdbritto|$HOME|g" "$HOME/.config/niri/personal.kdl"
  chmod +x "$HOME/.local/bin/futurista"
fi
quiere windows && copiar "$H" .config/labwc
if quiere hyprland; then
  copiar "$H" .config/hypr/hyprland.lua .config/hypr/parrot .config/hypr/temas .config/hypr/plantillas \
    .config/hypr/scripts .config/hypr/waybar .config/hypr/iconos .config/hypr/hyprlock.conf \
    .config/hypr/hypridle.conf .config/systemd/user/hyprpolkitagent.service.d
  # personal.lua es tuyo: solo se copia la primera vez
  [[ -f $HOME/.config/hypr/personal.lua ]] || cp "$H/.config/hypr/personal.lua" "$HOME/.config/hypr/"
  chmod +x "$HOME"/.config/hypr/scripts/*.sh
  "$HOME/.config/hypr/scripts/tema.sh" generar >/dev/null || aviso "No se pudieron crear los colores del tema de Hyprland."
fi
if quiere macos; then
  copiar "$H" .local/bin/estilo-plasma .local/bin/pantalla-login .local/share/plasma .local/share/aurorae \
    .local/share/color-schemes/WhiteSurParrot.colors .local/share/color-schemes/WhiteSurParrotDark.colors \
    .config/Kvantum/WhiteSurParrot .local/share/icons/WhiteSur-cursors .local/share/icons/hicolor \
    .local/share/sddm-themes/WhiteSurParrot .config/plasma-workspace/env/appmenu-gtk.sh \
    .config/systemd/user/plasma-modo-auto.service .config/systemd/user/plasma-modo-auto.timer
  # El logo de Parrot necesita el indice de iconos hicolor junto a el.
  [[ -f $HOME/.local/share/icons/hicolor/index.theme ]] ||
    cp /usr/share/icons/hicolor/index.theme "$HOME/.local/share/icons/hicolor/" 2>/dev/null || true
  chmod +x "$HOME/.local/bin/estilo-plasma" "$HOME/.local/bin/pantalla-login"
fi
quiere terminales && copiar "$H" .config/alacritty .config/foot .config/ghostty .config/kitty .config/xdg-terminals.list
quiere herramientas && copiar "$H" .config/mise .claude
quiere dictado && copiar "$H" .config/voxtype .config/systemd/user/voxtype.service
if quiere vmware && quiere niri; then
  copiar "$REPO/vmware" .config/niri/vmware.kdl
else
  rm -f "$HOME/.config/niri/vmware.kdl"
fi

# Comandos propios (sesion) disponibles en la terminal (bash y zsh).
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [[ -f $rc ]] || continue
  grep -q 'HOME/.local/bin' "$rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$rc"
done

if quiere apps; then xdg-settings set default-web-browser firefox-esr.desktop 2>/dev/null || true; fi
xdg-user-dirs-update 2>/dev/null || true
if [[ -d $RESPALDO ]]; then echo "Copia de tus archivos anteriores: $RESPALDO"; fi

# ---------------------------------------------------------------- fuente de las terminales
if quiere terminales && ! fc-list 2>/dev/null | grep -q "JetBrainsMono Nerd"; then
  verde "Instalando la fuente JetBrainsMono Nerd Font"
  FUENTES="$HOME/.local/share/fonts/JetBrainsMonoNerd"
  mkdir -p "$FUENTES"
  if curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
    tar -xJ -C "$FUENTES"; then
    fc-cache -f "$FUENTES" >/dev/null
  else
    aviso "No se pudo descargar la fuente; las terminales usaran otra."
  fi
fi

# ---------------------------------------------------------------- fondos
if quiere fondos; then
  verde "Creando galeria de fondos en ~/Pictures/Fondos"
  FONDOS="$HOME/Pictures/Fondos"
  mkdir -p "$FONDOS"
  n=0
  while IFS= read -r -d '' img; do
    rel=${img#/usr/share/}
    ln -sfn "$img" "$FONDOS/${rel//\//-}"
    n=$((n + 1))
  done < <(find /usr/share/backgrounds /usr/share/wallpapers -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) ! -iname 'screenshot*' -size +100k -print0 2>/dev/null)
  echo "$n fondos enlazados. Cambia el fondo con Super + Ctrl + Espacio."
fi

# ---------------------------------------------------------------- herramientas (mise)
if quiere herramientas; then
  verde "Instalando herramientas de desarrollo (claude, codex, gh, node, opencode)"
  MISE_MINIMUM_RELEASE_AGE=0 mise install --yes || aviso "mise no pudo instalar todo; reintenta luego con: mise install"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f $rc ]] || continue
    sh=$(basename "$rc" rc); sh=${sh#.}
    grep -q 'mise activate' "$rc" || echo "eval \"\$(mise activate $sh)\"" >>"$rc"
  done
fi

# ---------------------------------------------------------------- tienda de apps (Flatpak)
# Flatpak solo se usa desde la terminal; Bazaar es la tienda grafica y la que
# abre los archivos .flatpak con doble clic. No depende de GNOME ni de KDE.
if quiere tienda; then
  verde "Instalando la tienda de apps (Bazaar) desde Flathub"
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo ||
    aviso "No se pudo agregar Flathub."
  if sudo flatpak install -y --noninteractive flathub io.github.kolunmi.Bazaar; then
    xdg-mime default io.github.kolunmi.Bazaar.desktop application/vnd.flatpak application/vnd.flatpak.ref 2>/dev/null || true
  else
    aviso "No se pudo instalar Bazaar; reintenta luego con: flatpak install flathub io.github.kolunmi.Bazaar"
  fi
fi

# ---------------------------------------------------------------- dictado (voxtype)
if quiere dictado && command -v voxtype >/dev/null; then
  verde "Configurando dictado por voz (voxtype)"
  voxtype setup --download --no-post-install || aviso "No se pudo descargar el modelo de voxtype."
fi

# ---------------------------------------------------------------- servicios
verde "Activando servicios"
systemctl --user daemon-reload 2>/dev/null || true
if quiere dictado; then
  systemctl --user enable voxtype.service 2>/dev/null || aviso "No se pudo activar voxtype.service"
fi
if quiere vmware; then
  sudo systemctl enable --now open-vm-tools.service 2>/dev/null || true
fi
if quiere macos; then
  systemctl --user enable plasma-modo-auto.timer 2>/dev/null || aviso "No se pudo activar el cambio claro/oscuro automatico."
  sudo env TEMA_ORIGEN="$HOME/.local/share/sddm-themes/WhiteSurParrot" "$HOME/.local/bin/pantalla-login" macos ||
    aviso "No se pudo poner la pantalla de inicio estilo macOS."
  # El estilo se aplica desde dentro de Plasma: ahora si estamos en Plasma, o
  # solo la primera vez que se entre en Plasma.
  if [[ ${XDG_CURRENT_DESKTOP:-} == *KDE* ]] && pgrep -x plasmashell >/dev/null; then
    "$HOME/.local/bin/estilo-plasma" macos || aviso "No se pudo aplicar el estilo macOS; ejecuta: estilo-plasma macos"
  else
    PRIMERA="$HOME/.config/autostart/estilo-plasma-primera-vez.desktop"
    mkdir -p "$(dirname "$PRIMERA")"
    cat >"$PRIMERA" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Aplicar estilo macOS (una sola vez)
OnlyShowIn=KDE;
Exec=sh -c 'sleep 8; "$HOME/.local/bin/estilo-plasma" macos && rm -f "$PRIMERA"'
X-KDE-autostart-phase=2
DESKTOP
    echo "El estilo macOS se aplicara solo la primera vez que entres en Plasma."
  fi
fi
if quiere pantalla-inicio; then
  sudo systemctl enable sddm.service || aviso "No se pudo activar la pantalla de inicio (sddm)."
fi

# ---------------------------------------------------------------- modo futurista
if quiere futurista; then
  verde "Activando el modo futurista"
  "$HOME/.local/bin/futurista" on
elif quiere niri; then
  "$HOME/.local/bin/futurista" off >/dev/null
fi

# ---------------------------------------------------------------- fondo inicial
# Sin un fondo elegido, DMS no tiene de donde sacar los colores del tema (ni del
# modo futurista) ni carpeta para ir cambiando de fondo. Si ya hay uno, se deja.
if usa_dms; then
  verde "Eligiendo el fondo de pantalla"
  FONDO=""
  CARPETA_FONDOS=""
  if [[ -d $HOME/Pictures/Fondos ]] && ls "$HOME/Pictures/Fondos" | grep -q .; then
    CARPETA_FONDOS="$HOME/Pictures/Fondos"
    FONDO="$CARPETA_FONDOS/wallpapers-EchoWallpaper-contents-images-1920x1080.png"
    [[ -e $FONDO ]] || FONDO="$CARPETA_FONDOS/$(ls "$CARPETA_FONDOS" | head -n1)"
  elif [[ -e /usr/share/backgrounds/default.jpg ]]; then
    FONDO=/usr/share/backgrounds/default.jpg
  fi
  if [[ -n $FONDO ]]; then
    SESION_DMS="$HOME/.local/state/DankMaterialShell/session.json"
    mkdir -p "$(dirname "$SESION_DMS")"
    python3 -I - "$SESION_DMS" "$FONDO" "$CARPETA_FONDOS" <<'PY'
import json, os, sys
ruta, fondo, carpeta = sys.argv[1:4]
d = json.load(open(ruta)) if os.path.exists(ruta) else {}
if not d.get("wallpaperPath"):
    d["wallpaperPath"] = fondo
    print("Fondo:", fondo)
else:
    print("Se mantiene tu fondo:", d["wallpaperPath"])
if carpeta and not d.get("wallpaperCyclingFolderPath"):
    d["wallpaperCyclingFolderPath"] = carpeta
json.dump(d, open(ruta, "w"), indent=2)
PY
  else
    aviso "No encontre fondos; elige uno con Super + Ctrl + Espacio."
  fi
fi

# Volver a abrir DMS si estaba en marcha y estamos dentro de Niri.
if $DMS_ESTABA && [[ -n ${NIRI_SOCKET:-} ]]; then
  niri msg action spawn -- dms run >/dev/null 2>&1 || aviso "Abre DMS con: dms run"
fi

# ---------------------------------------------------------------- sesion de inicio
# Archivo .desktop de la sesion de cada estilo (macOS es la sesion de Plasma).
declare -A SESION_DE=([niri]=niri [windows]=labwc [hyprland]=hyprland [macos]=plasma)
SESION=${SESION_DE[$ARRANQUE]}
verde "Eligiendo ${NOMBRE_ARRANQUE[$ARRANQUE]} como escritorio de inicio"
AUTO=""
for f in /etc/sddm.conf.d/*.conf /etc/sddm.conf; do
  if [[ -f $f ]] && grep -q '^Session=' "$f"; then AUTO=$f; break; fi
done
if [[ -n $AUTO ]]; then
  sudo sed -i "s|^Session=.*|Session=$SESION.desktop|" "$AUTO"
  echo "El equipo entrara directamente en ${NOMBRE_ARRANQUE[$ARRANQUE]}."
elif [[ -f /etc/lightdm/lightdm.conf ]] && grep -q '^autologin-session=' /etc/lightdm/lightdm.conf; then
  sudo sed -i "s|^autologin-session=.*|autologin-session=$SESION|" /etc/lightdm/lightdm.conf
  echo "El equipo entrara directamente en ${NOMBRE_ARRANQUE[$ARRANQUE]}."
elif [[ $(cat /etc/X11/default-display-manager 2>/dev/null) == */sddm ]]; then
  # Sin inicio automatico, SDDM propone la ultima sesion usada: dejar elegida esta.
  ARCHIVO=$(ls /usr/share/wayland-sessions/"$SESION".desktop /usr/share/xsessions/"$SESION".desktop 2>/dev/null | head -n1)
  if [[ -n $ARCHIVO ]]; then
    sudo mkdir -p /var/lib/sddm
    printf '[Last]\nSession=%s\nUser=%s\n' "$ARCHIVO" "$USER" | sudo tee /var/lib/sddm/state.conf >/dev/null
    sudo chown sddm:sddm /var/lib/sddm/state.conf 2>/dev/null || true
    echo "La pantalla de inicio propondra ${NOMBRE_ARRANQUE[$ARRANQUE]}."
  fi
else
  echo "En la pantalla de inicio elige la sesion \"$SESION\" (queda recordado)."
fi

verde "Listo"
echo "Reinicia el equipo para ver todo aplicado. Arranca con: ${NOMBRE_ARRANQUE[$ARRANQUE]}."
echo
if quiere niri; then
  echo "  - Niri moderno: Super + K muestra los atajos, Super + Tab la vista general."
  quiere futurista && echo "    Modo futurista (animaciones y efectos):  futurista on  /  futurista off"
fi
usa_dms && echo "  - Aspecto Windows sobre DMS (barra abajo, tema azul):  undercover on  /  undercover off"
quiere windows && echo "  - Windows (labwc): sesion \"labwc\" en la pantalla de inicio, o:  sesion windows"
if quiere hyprland; then
  echo "  - Hyprland Parrot: sesion \"Hyprland\" en la pantalla de inicio, o:  sesion hyprland"
  echo "    Super + A ajustes rapidos · Super + K atajos · Super + Alt + T tema · Super + Alt + P modo rendimiento"
fi
if quiere macos; then
  echo "  - macOS (KDE Plasma): sesion \"Plasma\" en la pantalla de inicio, o:  sesion parrot"
  echo "    Modo claro/oscuro:  estilo-plasma claro  /  estilo-plasma oscuro"
fi
quiere tienda && echo "  - Tienda de apps: Bazaar (los .flatpak se abren con doble clic)"
echo "  - Cambiar el escritorio de inicio:  sesion niri | windows | hyprland | parrot"
echo
echo "Para agregar un estilo o algo que no elegiste, vuelve a ejecutar ./install.sh"

if ((${#AVISOS[@]})); then
  printf '\n\033[1;33mHubo %d aviso(s) durante la instalacion:\033[0m\n' "${#AVISOS[@]}"
  printf '  - %s\n' "${AVISOS[@]}"
fi
echo
echo "Registro completo: $LOG  (el ultimo siempre en ~/.cache/parrot-dotfiles/ultimo.log)"
