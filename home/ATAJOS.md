# Mis atajos de teclado — Parrot (bspwm + sxhkd + kitty + zsh)

`Super` = tecla Windows. Atajos de sistema en `~/.config/sxhkd/sxhkdrc`; atajos de terminal en `~/.config/kitty/kitty.conf`.
Si cambias el sxhkdrc, recárgalo con `Super + Esc`.

---

## Sistema y aplicaciones
| Atajo | Acción |
|---|---|
| `Super + Enter` | Abrir terminal (kitty) |
| `Super + Espacio` | **Buscar aplicaciones con iconos (rofi)** |
| `Super + D` | Lanzador de comandos (rofi) |
| `Super + Shift + F` | Abrir Firefox |
| `Super + Shift + X` | Bloquear pantalla (xsecurelock Matrix) |
| `Super + Shift + Esc` | **Menú apagar / reiniciar / cerrar sesión** |
| `Super + Ctrl + Espacio` | **Elegir fondo (cambia los colores de todo)** |
| `Impr` | Captura de un área (Shift = pantalla, Super = ventana) |
| `Super + N` | Volver a ver la última notificación |
| `Super + Shift + ,` | Borrar todas las notificaciones |
| `Super + H` | **Mostrar este listado de atajos (popup)** |
| `Super + Esc` | Recargar atajos (sxhkd) |
| `Super + Shift + R` | Reiniciar bspwm |
| `Super + Alt + Shift + Q` | **Salir de bspwm (cerrar sesión)** |

## Ventanas
| Atajo | Acción |
|---|---|
| `Super + Q` | Cerrar ventana |
| `Super + Shift + Q` | Forzar el cierre de la ventana (kill) |
| `Super + M` | Alternar mosaico / monocle |
| `Super + T` | Modo mosaico (tiled) |
| `Super + Shift + T` | Modo pseudo-mosaico |
| `Super + S` | Ventana flotante |
| `Super + F` | Pantalla completa |
| `Super + G` | Intercambiar con la ventana más grande |
| `Super + Y` | Enviar la ventana marcada a la preselección |
| `Super + Ctrl + M` | Marcar ventana |
| `Super + Ctrl + X` | Bloquear ventana (no se puede cerrar) |
| `Super + Ctrl + Y` | Fijar ventana (visible en todos los escritorios) |
| `Super + Ctrl + Z` | Ventana privada |
| `Super + arrastrar` | Mover ventana (clic izq.) o redimensionar (clic der.) |

## Foco, movimiento y tamaño
| Atajo | Acción |
|---|---|
| `Super + Flechas` | Mover el foco en esa dirección |
| `Super + Shift + Flechas` | Intercambiar la ventana en esa dirección |
| `Super + Ctrl + Flechas` | **Mover una ventana flotante (20 px)** |
| `Super + Alt + Flechas` | Redimensionar la ventana |
| `Super + C` / `Super + Shift + C` | Ventana siguiente / anterior |
| `Super + P` / `B` / `,` / `.` | Foco al padre / hermano / primero / segundo |
| `Super + O` / `Super + I` | Ventana anterior / siguiente en el historial |
| `Super + º` (tecla grave) | Última ventana usada |

## Escritorios (I – X)
| Atajo | Acción |
|---|---|
| `Super + 1 … 9, 0` | Ir al escritorio I … X |
| `Super + Shift + 1 … 9, 0` | Enviar la ventana al escritorio I … X |
| `Super + Tab` | Último escritorio usado |
| `Super + [` / `Super + ]` | Escritorio anterior / siguiente |

## Preselección (dónde se abre la próxima ventana)
| Atajo | Acción |
|---|---|
| `Super + Ctrl + Alt + Flechas` | Preseleccionar dirección |
| `Super + Ctrl + 1 … 9` | Proporción de la división (10 % … 90 %) |
| `Super + Ctrl + Alt + Espacio` | Cancelar la preselección de la ventana |
| `Super + Ctrl + Shift + Espacio` | Cancelar todas las preselecciones del escritorio |

---

## Terminal kitty
| Atajo | Acción |
|---|---|
| `Ctrl + Shift + Enter` | Dividir la ventana (mismo directorio) |
| `Ctrl + Shift + T` | Nueva pestaña (mismo directorio) |
| `Ctrl + Flechas` | Moverse entre paneles divididos |
| `Ctrl + Shift + Z` | Ampliar o restaurar el panel actual |
| `Ctrl + Shift + C` / `V` | Copiar / pegar |
| `F1` / `F2` | Copiar / pegar en el portapapeles "a" |
| `F3` / `F4` | Copiar / pegar en el portapapeles "b" |
| `Ctrl + Shift + W` | Cerrar el panel (por defecto de kitty) |
| `Ctrl + Shift + Q` | Cerrar la pestaña (por defecto de kitty) |
| `Ctrl + Shift + ←` / `→` | Pestaña anterior / siguiente (por defecto) |

## Zsh (plugins)
| Atajo | Acción |
|---|---|
| `Esc Esc` | Añadir `sudo` delante del comando (zsh-sudo) |
| `→` o `Fin` | Aceptar la sugerencia gris (autosuggestions) |
| `Ctrl + R` | Buscar en el historial (fzf) |
| `Ctrl + T` | Buscar un archivo e insertar su ruta (fzf) |
| `Alt + C` | Cambiar de directorio buscando (fzf) |

## Comandos de la terminal (target / red)
Funciones de zsh (`~/.zshrc`). Se escriben en la terminal, no son atajos de teclado.
| `Super + Shift + V` | **Popup para fijar/borrar el objetivo** (pide IP y nombre; IP vacía = borrar) |
| `settarget <ip> <nombre>` | Fija el objetivo y copia la IP al portapapeles (ej: `settarget 10.10.15.5 Blue`) |
| `cleartarget` | Borra el objetivo → la polybar vuelve a "No target" |
| `$TARGET` | Variable con la IP del objetivo actual (ej: `nmap -sCV $TARGET`, `ffuf -u http://$TARGET/FUZZ ...`) |
| `$TARGET_NAME` | Variable con el nombre del objetivo actual |

## Módulos de la polybar (barra superior)
| Módulo "No target" | Objetivo actual; se cambia con `settarget` / `cleartarget` (al lado del botón de apagado) |
| Icono de apagado | Clic izquierdo → menú de apagado/reinicio/cerrar sesión (powermenu) |
| Icono de red azul | IP de tu tarjeta cableada (ens33) |
| Icono de candado verde | IP de la VPN (tun0) si estás conectado; si no, "Disconnected" |

---

## Combinaciones libres (para añadir atajos nuevos)
Estas combinaciones no están en uso: `Super + A`, `Super + E`, `Super + J`, `Super + K`, `Super + L`,
`Super + N`, `Super + R`, `Super + U`, `Super + W`, `Super + X`, `Super + Z`, `Super + Espacio`, `Print`.

## Cambios del 2026-10-20 (conflictos corregidos)
- **Salir de bspwm**: pasó de `Super + Shift + Q` a `Super + Alt + Shift + Q`, porque chocaba con "forzar el cierre de la ventana".
- **Mover una ventana flotante**: pasó de `Super + Shift + Flechas` a `Super + Ctrl + Flechas`, porque chocaba con "intercambiar ventana".
- Nuevo atajo `Super + H`: abre un popup (rofi) con este listado, generado por `~/.config/bspwm/scripts/atajos`.
- Copia de seguridad del archivo original: `~/.config/sxhkd/sxhkdrc.bak-2026-10-20`
