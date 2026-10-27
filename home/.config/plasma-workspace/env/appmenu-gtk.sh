# Menu global (barra de arriba) para apps GTK. Solo se carga en sesiones de Plasma.
case ":${GTK_MODULES:-}:" in
  *:appmenu-gtk-module:*) ;;
  *) export GTK_MODULES="${GTK_MODULES:+$GTK_MODULES:}appmenu-gtk-module" ;;
esac
