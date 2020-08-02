#!/bin/sh

. /lib/libsoteria.sh

[ "$ACTION" = "ifup" ] && [ "$INTERFACE" = "soteria" ] && {
  sleep 1
  tinysrv_check
}

[ "$ACTION" = "ifup" ] && [ "$INTERFACE" = "wan" ] && {
  sleep 1
  soteria_run
}