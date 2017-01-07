#!/bin/sh

. /lib/libsoteria.sh

[ "$ACTION" = "ifup" ] && [ "$INTERFACE" = "soteria" ] && {
  sleep 1
  is_running `tinysrv_pid` || start_tinysrv
}

[ "$ACTION" = "ifup" ] && [ "$INTERFACE" = "wan" ] && {
  sleep 1
  refresh_hosts
}
