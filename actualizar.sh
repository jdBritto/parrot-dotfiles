#!/bin/bash
# Copia tu configuracion actual al repositorio y la sube a GitHub.
# Uso:  ./actualizar.sh "mensaje opcional"

set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Actualiza cada archivo que ya esta en el repositorio con su version actual.
ARBOLES=(home)
[[ $(systemd-detect-virt 2>/dev/null || true) == vmware ]] && ARBOLES+=(vmware)
for arbol in "${ARBOLES[@]}"; do
  while IFS= read -r -d '' f; do
    rel=${f#"$REPO/$arbol"/}
    if [[ -f $HOME/$rel ]]; then cp -a "$HOME/$rel" "$f"; fi
  done < <(find "$REPO/$arbol" -type f -print0)
done

# install.sh cambia /home/jdbritto por la carpeta de cada usuario: guardarlo
# siempre con ese marcador y no con la ruta de este equipo.
for f in home/.config/matugen/config.toml home/.config/niri/personal.kdl; do
  [[ -f $REPO/$f ]] && sed -i "s|$HOME/|/home/jdbritto/|g" "$REPO/$f"
done

cd "$REPO"
git add -A
if git diff --cached --quiet; then
  echo "No hay cambios que subir."
else
  git commit -m "${1:-Actualizar configuracion $(date +%F)}"
  git push
  echo "Configuracion subida a GitHub."
fi
