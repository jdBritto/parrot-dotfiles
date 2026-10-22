# parrot-dotfiles

Mi escritorio **Niri + [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)**
para **Parrot OS 7** (también funciona en Debian 13 "trixie", que es su base).
Es el mismo escritorio que uso en Omarchy ([omarchy-dotfiles](https://github.com/jdBritto/omarchy-dotfiles)),
con los mismos atajos, adaptado a Parrot.

El escritorio original de Parrot (KDE Plasma, MATE, etc.) **no se toca**: sigue
disponible en la pantalla de inicio.

## Instalar

1. Instala Parrot OS 7 (cualquier edición) y entra con tu usuario.
2. Abre una terminal y ejecuta:

```bash
sudo apt install -y git
git clone https://github.com/jdBritto/parrot-dotfiles.git ~/parrot-dotfiles
~/parrot-dotfiles/install.sh
```

   Al empezar muestra una lista para elegir qué instalar (escribes los números
   para marcar o desmarcar). Para instalar lo recomendado sin preguntas:
   `install.sh --si`.

3. Reinicia y, en la pantalla de inicio, elige la sesión **Niri**.

### Qué hace el instalador

- Agrega los repositorios oficiales de DankLinux (Niri, Ghostty, matugen…) y de
  DMS, e instala `quickshell` desde `echo-backports` de Parrot, como indica la
  [guía de instalación de DMS](https://danklinux.com/docs/dankmaterialshell/installation).
- Instala `qt6-wayland` (sin él DMS no abre y el escritorio queda vacío) y
  agrega tu usuario al grupo `input`.
- Hace que DMS arranque **solo** con Niri (el paquete de Debian lo activaría
  también en KDE y chocaría con su panel).
- Copia la configuración de Niri, DMS y las terminales.
- Opcional: terminales con la fuente JetBrainsMono Nerd, Firefox, herramientas
  de desarrollo con `mise` (claude, codex, gh, node, opencode), dictado por voz
  (voxtype), galería de fondos con los de Parrot y ajustes para VMware (solo se
  ofrecen si detecta una máquina virtual VMware).
- Antes de sobrescribir guarda una copia en `~/.config-respaldo-<fecha>`.
  Es seguro ejecutarlo más de una vez.

## Cambiar de escritorio

En la pantalla de inicio eliges la sesión (queda recordada). Si el equipo entra
solo (inicio automático), usa en una terminal:

```bash
sesion niri       # arrancar con Niri
sesion parrot     # volver al escritorio de Parrot
sesion estado     # ver cuál está elegido
```

## Atajos principales (Niri)

| Atajo | Qué hace |
|---|---|
| `Super + K` | Ver todos los atajos |
| `Super + Enter` | Terminal |
| `Super + Espacio` | Buscar aplicaciones |
| `Super + Tab` | Vista general |
| `Super + W` | Cerrar ventana |
| `Super + Shift + B` | Navegador |
| `Super + Shift + F` | Archivos |
| `Super + I` | Configuración de DMS |
| `Super + Ctrl + Espacio` | Cambiar fondo |
| `Super + Ctrl + X` | Dictado por voz |
| `Super + Escape` | Apagar / reiniciar |

## Modo futurista

Opcional en el instalador (viene marcado) y solo para Niri. Añade:

- **Animaciones:** las ventanas se abren como un holograma (una línea de luz las
  dibuja con líneas de escaneo) y se cierran como una pantalla vieja (CRT).
  Movimientos con un rebote ligero.
- **Borde neón** con degradado y brillo alrededor de la ventana activa.
- **Cristal:** terminales, barra y menús semitransparentes con el fondo desenfocado.
- **Colores que siguen al fondo:** DMS saca una paleta viva de cada fondo y con
  ella pinta la barra, los paneles, la terminal, el borde neón y las animaciones.
- **Fondos** que cambian solos cada 10 minutos con transiciones aleatorias
  (disolver, barrido, círculo, pixelado, portal…).

```bash
futurista on       # activarlo
futurista off      # volver al estilo normal
futurista estado   # ver si está activo
```

La parte de Niri está en `~/.config/niri/futurista.kdl`. Los colores del borde y
de las animaciones salen de la plantilla
`~/.config/matugen/templates/futurista-colores.kdl`, que DMS vuelve a generar en
cada cambio de fondo.

## Guardar cambios de configuración

```bash
~/parrot-dotfiles/actualizar.sh "lo que cambié"
```

(Para agregar un archivo nuevo, cópialo dentro de `home/` con la misma ruta que
tiene en tu carpeta personal.)

## Qué contiene

| Carpeta / archivo | Qué es |
|---|---|
| `install.sh` | Instalador |
| `actualizar.sh` | Sube tu configuración actual al repositorio |
| `paquetes/` | Listas de paquetes por componente |
| `home/` | Configuración (Niri, DMS, terminales, mise, voxtype, modo futurista) y los comandos `sesion` y `futurista` |
| `vmware/` | Ajustes que solo se usan en VMware |
