#!/bin/sh

. /lib/libsoteria.sh

[ -n "$1" ] || {
  echo "Missing option" >&2
  exit 1
}

case "$1" in

  refresh)
    soteria_run
    ;;

esac