#!/bin/bash
# Instala mi escritorio Niri + DankMaterialShell (DMS) en Parrot OS 7.
# (Tambien sirve en Debian 13 "trixie", que es la base de Parrot 7.)
# Al empezar muestra un menu para elegir que instalar (flechas y Espacio).
#
# Uso:  ./install.sh         (pregunta todo)
#       ./install.sh --si    (sin preguntas: lo recomendado)
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
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- opciones
PREGUNTAR=true
for arg in "$@"; do
  case "$arg" in
    --si)      PREGUNTAR=false ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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
  printf '\033[2m  Escritorio Niri + DankMaterialShell para %s\033[0m\n\n' "${PRETTY_NAME:-Parrot OS 7}"
}

# ---------------------------------------------------------------- que instalar
IDS=()
declare -A NOMBRE DESC MARCA
agregar() { IDS+=("$1"); NOMBRE[$1]=$2; DESC[$1]=$3; MARCA[$1]=$4; }

$TIENE_PANTALLA_INICIO || agregar pantalla-inicio "Pantalla de inicio (SDDM)" "Este equipo no tiene pantalla de inicio de sesion; instala SDDM." si
agregar futurista "Modo futurista" "Animaciones holograma, borde neon y cristal; los colores siguen al fondo." si
agregar terminales "Terminales" "Ghostty, Kitty, Alacritty y Foot con su configuracion y la fuente JetBrainsMono Nerd." si
agregar apps "Apps" "Firefox, nano y cava." si
agregar tienda "Tienda de apps (Bazaar)" "Flatpak con Flathub y la tienda Bazaar; abre los .flatpak con doble clic." no
agregar herramientas "Herramientas de desarrollo" "claude, codex, gh, node y opencode (con mise)." si
[[ $ARQ == amd64 ]] && agregar dictado "Dictado por voz" "voxtype: dictas con Super + Ctrl + X." si
agregar fondos "Galeria de fondos" "Enlaza los fondos que trae Parrot en ~/Pictures/Fondos." si
$ES_VMWARE && agregar vmware "Ajustes para VMware" "Resolucion, renderizado y herramientas de la maquina virtual." si

quiere() { [[ ${MARCA[$1]:-no} == si ]]; }
cambiar() { if quiere "$1"; then MARCA[$1]=no; else MARCA[$1]=si; fi; }

# Menu con flechas: se mueve con arriba/abajo (o j/k), Espacio marca o desmarca.
menu() {
  local actual=0 total=${#IDS[@]} tecla resto i id marca
  printf '\033[?25l'                 # ocultar el cursor mientras se elige
  trap 'printf "\033[?25h"' EXIT
  while true; do
    printf '\033[H\033[2J'
    logo
    echo "  Elige que instalar (Niri y DankMaterialShell se instalan siempre):"
    echo
    for i in "${!IDS[@]}"; do
      id=${IDS[i]}
      if quiere "$id"; then marca='\033[1;32m[x]\033[0m'; else marca='\033[2m[ ]\033[0m'; fi
      if ((i == actual)); then
        printf '  \033[1;36m❯\033[0m %b \033[1;36m%s\033[0m\n' "$marca" "${NOMBRE[$id]}"
      else
        printf '    %b %s\n' "$marca" "${NOMBRE[$id]}"
      fi
    done
    printf '\n  \033[3m%s\033[0m\n\n' "${DESC[${IDS[actual]}]}"
    printf '  \033[2m↑↓ moverse   Espacio marcar   a todo   n nada   Enter continuar   q salir\033[0m\n'

    IFS= read -rsn1 tecla || exit 1
    if [[ $tecla == $'\e' ]]; then   # las flechas llegan como Esc + [A / [B
      IFS= read -rsn2 -t 0.1 resto || true
      tecla+=$resto
    fi
    case $tecla in
      $'\e[A' | k) actual=$(((actual - 1 + total) % total)) ;;
      $'\e[B' | j) actual=$(((actual + 1) % total)) ;;
      ' ') cambiar "${IDS[actual]}" ;;
      [1-9]) if ((tecla <= total)); then actual=$((tecla - 1)); cambiar "${IDS[actual]}"; fi ;;
      a | A) for id in "${IDS[@]}"; do MARCA[$id]=si; done ;;
      n | N) for id in "${IDS[@]}"; do MARCA[$id]=no; done ;;
      '') break ;;
      q | Q) printf '\033[H\033[2J'; echo "Cancelado. No se cambio nada."; exit 0 ;;
    esac
  done
  printf '\033[?25h\033[H\033[2J'
  logo
}

if $PREGUNTAR; then menu; else logo; fi

echo "Se va a instalar: Niri, DankMaterialShell$(for id in "${IDS[@]}"; do quiere "$id" && printf ', %s' "${NOMBRE[$id]}"; done)"
if $PREGUNTAR; then
  read -rp "Continuar? [S/n] " r
  [[ $r =~ ^[nN]$ ]] && { echo "Cancelado. No se cambio nada."; exit 0; }
fi
sudo -v || error "Hace falta tu contrasena de administrador."

# ---------------------------------------------------------------- repositorios
verde "Agregando repositorios (DankLinux y DMS)"
apt_ update
apt_ install -y curl gpg ca-certificates
sudo install -d -m 0755 /etc/apt/keyrings

agregar_repo() { # agregar_repo NOMBRE URL_CLAVE LINEA_DEB
  local nombre=$1 clave=$2 linea=$3
  curl -fsSL "$clave" | sudo gpg --dearmor --yes -o "/etc/apt/keyrings/$nombre.gpg"
  echo "deb [signed-by=/etc/apt/keyrings/$nombre.gpg] $linea" | sudo tee "/etc/apt/sources.list.d/$nombre.list" >/dev/null
}
agregar_repo duxlabs "$OBS:/danklinux/Debian_13/Release.key" "$OBS:/danklinux/Debian_13/ /"
agregar_repo avengemedia-dms "$OBS:/dms/Debian_13/Release.key" "$OBS:/dms/Debian_13/ /"
if quiere herramientas; then
  agregar_repo mise https://mise.jdx.dev/gpg-key.pub "https://mise.jdx.dev/deb stable main"
fi

# quickshell (la base de DMS) debe venir de los backports de Parrot/Debian,
# no del repositorio de DankLinux, que esta obsoleto para Debian.
if [[ $BACKPORTS == trixie-backports ]] && ! grep -rqs "trixie-backports" /etc/apt/sources.list /etc/apt/sources.list.d/; then
  echo "deb http://deb.debian.org/debian trixie-backports main" | sudo tee /etc/apt/sources.list.d/trixie-backports.list >/dev/null
fi
if [[ $BACKPORTS == echo-backports ]] && ! grep -rqs "echo-backports" /etc/apt/sources.list /etc/apt/sources.list.d/; then
  echo "deb https://deb.parrot.sh/parrot echo-backports main contrib non-free non-free-firmware" |
    sudo tee /etc/apt/sources.list.d/parrot-backports.list >/dev/null
fi
printf 'Package: quickshell\nPin: origin download.opensuse.org\nPin-Priority: -1\n' |
  sudo tee /etc/apt/preferences.d/quickshell-backports >/dev/null

# ---------------------------------------------------------------- paquetes
verde "Instalando paquetes"
apt_ update
apt_ install -y -t "$BACKPORTS" quickshell || error "No se pudo instalar quickshell desde $BACKPORTS."

leer_lista() { grep -vE '^\s*(#|$)' "$REPO/paquetes/$1.txt"; }
PAQUETES=()
mapfile -t -O 0 PAQUETES < <(leer_lista dms; leer_lista niri)
for id in "${IDS[@]}"; do
  if quiere "$id" && [[ -f $REPO/paquetes/$id.txt ]]; then
    mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(leer_lista "$id")
  fi
done
echo "Instalando: ${PAQUETES[*]}"
apt_ install -y "${PAQUETES[@]}" || error "No se pudieron instalar algunos paquetes."

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

# ---------------------------------------------------------------- archivos
copiar() { # copiar ORIGEN RUTA...: copia esas rutas de ORIGEN a $HOME, respaldando lo que ya exista
  local origen=$1; shift
  local ruta f rel destino
  for ruta in "$@"; do
    [[ -e $origen/$ruta ]] || continue
    while IFS= read -r -d '' f; do
      rel=${f#"$origen"/}
      destino="$HOME/$rel"
      if [[ -e $destino ]] && ! cmp -s "$f" "$destino"; then
        mkdir -p "$(dirname "$RESPALDO/$rel")"
        cp -a "$destino" "$RESPALDO/$rel"
      fi
      mkdir -p "$(dirname "$destino")"
      cp -a "$f" "$destino"
    done < <(find "$origen/$ruta" -type f -print0)
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
copiar "$H" .config/niri .config/DankMaterialShell .config/matugen .local/bin/sesion .local/bin/futurista
quiere terminales && copiar "$H" .config/alacritty .config/foot .config/ghostty .config/kitty .config/xdg-terminals.list
quiere herramientas && copiar "$H" .config/mise .claude
quiere dictado && copiar "$H" .config/voxtype .config/systemd/user/voxtype.service
if quiere vmware; then
  copiar "$REPO/vmware" .config/niri/vmware.kdl
else
  rm -f "$HOME/.config/niri/vmware.kdl"
fi

# Niri no entiende $HOME en su configuracion: poner la ruta real.
sed -i "s|/home/jdbritto|$HOME|g" "$HOME/.config/niri/personal.kdl" "$HOME/.config/matugen/config.toml"
chmod +x "$HOME/.local/bin/sesion" "$HOME/.local/bin/futurista"

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
if quiere pantalla-inicio; then
  sudo systemctl enable sddm.service || aviso "No se pudo activar la pantalla de inicio (sddm)."
fi

# ---------------------------------------------------------------- modo futurista
if quiere futurista; then
  verde "Activando el modo futurista"
  "$HOME/.local/bin/futurista" on
else
  "$HOME/.local/bin/futurista" off >/dev/null
fi

# ---------------------------------------------------------------- fondo inicial
# Sin un fondo elegido, DMS no tiene de donde sacar los colores del tema (ni del
# modo futurista) ni carpeta para ir cambiando de fondo. Si ya hay uno, se deja.
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

# Volver a abrir DMS si estaba en marcha y estamos dentro de Niri.
if $DMS_ESTABA && [[ -n ${NIRI_SOCKET:-} ]]; then
  niri msg action spawn -- dms run >/dev/null 2>&1 || aviso "Abre DMS con: dms run"
fi

# ---------------------------------------------------------------- sesion de inicio
verde "Eligiendo Niri como escritorio de inicio"
AUTO=""
for f in /etc/sddm.conf.d/*.conf /etc/sddm.conf; do
  if [[ -f $f ]] && grep -q '^Session=' "$f"; then AUTO=$f; break; fi
done
if [[ -n $AUTO ]]; then
  sudo sed -i "s|^Session=.*|Session=niri.desktop|" "$AUTO"
  echo "El equipo entrara directamente en Niri."
elif [[ -f /etc/lightdm/lightdm.conf ]] && grep -q '^autologin-session=' /etc/lightdm/lightdm.conf; then
  sudo sed -i "s|^autologin-session=.*|autologin-session=niri|" /etc/lightdm/lightdm.conf
  echo "El equipo entrara directamente en Niri."
else
  echo "En la pantalla de inicio elige la sesion \"Niri\" (queda recordado)."
fi

verde "Listo"
echo "Reinicia el equipo para ver todo aplicado."
echo
echo "  - Escritorio: Niri con DankMaterialShell."
echo "  - Super + K muestra todos los atajos. Super + Tab, la vista general."
echo "  - Modo futurista (animaciones y efectos):  futurista on  /  futurista off"
quiere tienda && echo "  - Tienda de apps: Bazaar (los .flatpak se abren con doble clic)"
echo "  - Para volver al escritorio de Parrot: elige otra sesion en la pantalla"
echo "    de inicio, o en una terminal:  sesion parrot"
echo
echo "Para agregar algo que no elegiste, vuelve a ejecutar ./install.sh"
