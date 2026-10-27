# parrot-dotfiles

Estilos de escritorio para **Parrot OS 7** (también funciona en Debian 13
"trixie", que es su base). Eliges uno o varios al instalar:

| Estilo | Qué es |
|---|---|
| **Niri moderno** | Niri + [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell): ventanas en columnas. Es el mismo escritorio que uso en Omarchy ([omarchy-dotfiles](https://github.com/jdBritto/omarchy-dotfiles)), con los mismos atajos. Opcional: modo futurista. |
| **Windows** | labwc con la barra de DankMaterialShell: ventanas flotantes y atajos de Windows. |
| **Hyprland Parrot** | Hyprland con 7 temas que se cambian al instante, barra, menús fáciles (`Super + A`), columnas como Niri y modo rendimiento. Inspirado en los [dotfiles de gh0stzk](https://github.com/gh0stzk/dotfiles). |
| **macOS** | KDE Plasma con la forma de macOS y la identidad de Parrot (iconos, verde, logo y fondo). |

Cada estilo es una sesión de la pantalla de inicio; el instalador pregunta con
cuál arranca el equipo.

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

   Al empezar muestra un menú en dos partes: **estilos del escritorio** (puedes
   marcar varios) y **extras**. Te mueves con las flechas (o `j`/`k`), marcas o
   desmarcas con **Espacio** (o con el número de la opción), `a` marca todo,
   `n` nada, **Enter** continúa y `q` sale sin cambiar nada. Si marcaste más de
   un estilo, después eliges **con cuál arranca el equipo**.
   Sin preguntas (Niri moderno, futurista y Windows, arranca en Niri):
   `install.sh --si`.

3. Reinicia. Para cambiar de estilo, elige otra sesión en la pantalla de inicio
   (**Niri**, **labwc** o **Plasma**) o usa el comando `sesion`.

### Qué hace el instalador

- Con Niri o Windows: agrega los repositorios oficiales de DankLinux (Niri,
  Ghostty, matugen…) y de DMS, e instala `quickshell` desde `echo-backports` de Parrot, como indica la
  [guía de instalación de DMS](https://danklinux.com/docs/dankmaterialshell/installation).
- Instala `qt6-wayland` (sin él DMS no abre y el escritorio queda vacío) y
  agrega tu usuario al grupo `input`.
- Hace que DMS arranque **solo** con Niri (el paquete de Debian lo activaría
  también en KDE y chocaría con su panel).
- Copia la configuración de cada estilo elegido. Si eliges solo macOS, no
  instala Niri ni DankMaterialShell.
- Opcional: terminales con la fuente JetBrainsMono Nerd, Firefox, tienda de apps
  [Bazaar](https://github.com/kolunmi/bazaar) con Flatpak y Flathub (abre los
  `.flatpak` con doble clic; viene desmarcada), herramientas
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
sesion windows    # arrancar con el escritorio estilo Windows (labwc)
sesion hyprland   # arrancar con Hyprland Parrot
sesion parrot     # Plasma: el escritorio de Parrot o el estilo macOS (también: sesion macos)
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

## Escritorio estilo Windows (labwc)

Opcional en el instalador (viene marcado). Es otro escritorio, con la misma barra
y menús de DMS, pero con las **ventanas de siempre**: flotantes, con
minimizar / maximizar / cerrar a la derecha y que se acoplan al arrastrarlas a
un borde. Ideal para empezar si vienes de Windows; cuando quieras más libertad,
pasa a Niri.

En la pantalla de inicio elige la sesión **labwc**, o en una terminal:
`sesion windows` (y `sesion niri` para volver).

| Atajo | Qué hace |
|---|---|
| `Win` (sola) / `Win + S` | Menú de inicio (buscar aplicaciones) |
| `Win + E` | Explorador de archivos |
| `Alt + F4` | Cerrar ventana |
| `Alt + Tab` | Cambiar de ventana |
| `Win + ← / →` | Acoplar la ventana a media pantalla |
| `Win + ↑ / ↓` | Maximizar / minimizar |
| `Ctrl + Win + ← / →` | Cambiar de escritorio virtual |
| `Win + Shift + S` / `Impr Pant` | Captura de pantalla |
| `Win + L` | Bloquear |
| `Ctrl + Shift + Esc` | Administrador de tareas |
| `Win + I` | Configuración |
| Clic derecho en el escritorio | Menú (terminal, fondo, configuración…) |

La configuración está en `~/.config/labwc/` (`rc.xml` atajos y ventanas,
`menu.xml` menú del clic derecho). Aplica tus cambios con `labwc -r`. Las barras de
título toman los colores del fondo, igual que el resto del escritorio.

## Hyprland Parrot

Hyprland 0.55 (desde `echo-backports`: la versión del repositorio principal de
Parrot no se puede instalar) con la identidad de Parrot. Las ideas vienen de los
[dotfiles de gh0stzk](https://github.com/gh0stzk/dotfiles): temas con paletas
hechas a mano que se cambian al instante, menús para todo y efectos que se
pueden apagar.

- **7 temas**: Parrot (verde, por defecto), Lorikeet, Vaporwave, HackTheBox,
  Nefelibata, Mystic y Claro. Cada uno cambia al momento los bordes, la barra,
  el lanzador, las notificaciones, la terminal, la pantalla de bloqueo, el menú
  de apagado y el fondo. Cada tema recuerda el fondo que le elijas.
- **Centro Parrot** (`Super + A`): tema, fondo, modo de rendimiento, luz
  nocturna, no molestar, wifi, bluetooth, sonido, pantallas, capturas…
- **Modo de rendimiento** (`Super + Alt + P` o el icono de la barra):
  *equilibrado* (todos los efectos), *rendimiento* (sin desenfoque ni sombras,
  CPU en `performance`) y *ahorro* (sin efectos ni animaciones, `power-saver`).
- **Tres formas de ordenar las ventanas** (`Super + D`): mosaico, columnas
  (como Niri) y principal con pila. Además: minimizar (`Super + M`), pestañas
  (`Super + G`), terminal desplegable (`Super + |`), arrastrar con `Super` +
  ratón, cambiar el tamaño desde el borde y gestos del touchpad (3 dedos).
- **Barra** en dos estilos: *islas* (bloques flotantes) y *panel*
  (`Super + Alt + B`); `Super + B` la oculta.

| Atajo | Qué hace |
|---|---|
| `Super + K` | Ver todos los atajos |
| `Super + A` | Centro Parrot (ajustes rápidos) |
| `Super + Espacio` | Buscar aplicaciones |
| `Super + Enter` | Terminal |
| `Super + Tab` / `Alt + Tab` | Lista de ventanas / siguiente ventana |
| `Super + W` | Cerrar ventana |
| `Super + T` / `Super + F` | Flotante / pantalla completa |
| `Super + Alt + T` | Cambiar tema |
| `Super + Ctrl + Espacio` | Cambiar fondo |
| `Super + V` | Portapapeles |
| `Impr Pant` / `Super + Shift + S` | Captura de una zona / y editarla |
| `Super + Ctrl + L` | Bloquear |
| `Super + Escape` | Apagar / reiniciar |

La configuración está en `~/.config/hypr/` (en Lua, el formato nuevo de
Hyprland): `parrot/` las partes, `temas/` los colores (puedes copiar uno y
crear el tuyo), `scripts/` los menús. Tus cambios van en
`~/.config/hypr/personal.lua`, que el instalador nunca sobrescribe.

La misma configuración, con su propio instalador para CachyOS, está en
[cachyos-dotfiles](https://github.com/jdBritto/cachyos-dotfiles).

## KDE Plasma estilo macOS (Parrot)

Estilo del instalador (viene desmarcado). Le da a Plasma la forma de macOS y
mantiene la identidad de Parrot:

- **De macOS:** barra arriba con el menú de la app, dock flotante abajo,
  botones cerrar/minimizar/maximizar a la izquierda, fuente Inter, efecto
  "genio", buscador al centro con `Meta+Espacio` (como Spotlight) y Launchpad.
- **De Parrot:** sus iconos (Flat-Remix-Green-Dark), el verde de Parrot en vez
  del azul de Mac, el logo de Parrot donde Mac pone la manzana y el fondo Echo.
- **Claro de día, oscuro de noche** (de 7:00 a 19:00), solo.
- **Pantalla de inicio** estilo macOS (SDDM) con el fondo y el logo de Parrot.

Se aplica solo la primera vez que entras en la sesión **Plasma**; Niri no cambia. A mano:

```bash
estilo-plasma macos      # aplicar el estilo
estilo-plasma claro      # modo claro (o: oscuro)
estilo-plasma deshacer   # dejar Plasma como estaba
pantalla-login lightdm   # volver a la pantalla de inicio de Parrot (pide contraseña)
systemctl --user disable --now plasma-modo-auto.timer   # sin cambio automático
```

Temas basados en [WhiteSur](https://github.com/vinceliuice/WhiteSur-kde) (GPL-3.0).

## Modo undercover (aspecto Windows)

Inspirado en *Kali Undercover*, pero para Wayland: funciona en **Niri y en labwc**
(el original solo funciona en XFCE). Pone la barra de tareas abajo con el botón de
inicio, las aplicaciones abiertas y el reloj a la derecha; tema y fondo azules;
quita el dock y los efectos del modo futurista. Útil en lugares públicos o para
que el cambio desde Windows no sea brusco.

```bash
undercover on        # activarlo   (en Niri también: Super + Ctrl + Shift + U)
undercover off       # volver exactamente a como estaba
undercover estado
```

Antes de cambiar nada guarda tu configuración en
`~/.local/state/parrot-dotfiles/undercover/`, y `undercover off` la restaura.

## De Windows a Linux: dónde está cada cosa

| En Windows | Aquí |
|---|---|
| Menú Inicio | `Super + Espacio` (o la tecla Win sola en labwc) |
| Explorador de archivos | `Super + E` (Nautilus) |
| Panel de control / Configuración | `Super + I` (DMS) |
| Microsoft Store | Bazaar (opción "Tienda de apps" del instalador) |
| Administrador de tareas | `Ctrl + Shift + Esc` |
| Herramienta Recortes | `Super + Shift + S` |
| Cerrar ventana | `Alt + F4` (también `Super + W`) |
| Bloquear (Win + L) | `Super + L` en labwc, `Super + Ctrl + L` en Niri |
| Instalar un `.exe` | No funcionan: busca la app en Bazaar o en la terminal con `apt search` |
| Actualizar el sistema | `sudo apt update && sudo apt full-upgrade` |

**¿Niri o labwc?** labwc se maneja como Windows: ventanas sueltas que mueves con el
ratón. Niri pone las ventanas en **columnas sobre una tira infinita**: cada ventana
nueva se abre a la derecha sin tapar las demás y te desplazas con `Super + ← / →`
o la rueda del ratón; `Super + Tab` muestra todo desde arriba. Cuesta un par de
días, pero nunca más tienes ventanas encimadas. Puedes tener los dos y cambiar
cuando quieras.

## Si algo falla en la instalación

Todo lo que muestra el instalador queda guardado en
`~/.cache/parrot-dotfiles/ultimo.log`, y al final lista los avisos. Lo más común:

- **Falla `apt update`** (un repositorio o mirror caído): espera unos minutos y
  ejecuta `sudo apt update --fix-missing`; luego vuelve a ejecutar `./install.sh`.
- **El escritorio queda negro con solo el cursor**: DMS no abrió. Ejecuta
  `dms doctor` en una terminal (`Super + Enter`) para ver qué falta.
- Servicios en rojo como `hostapd-wpe`, `sslh` o `isc-dhcp-server` vienen de
  `parrot-tools` (no de este repositorio) y fallan porque no están configurados;
  no afectan al escritorio.

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
| `home/` | Configuración (Niri, DMS, Hyprland Parrot, terminales, mise, voxtype, modo futurista) escritorio labwc y los comandos `sesion`, `futurista` y `undercover` |
| `vmware/` | Ajustes que solo se usan en VMware |
