#!/bin/sh

DNS_PARTS="cfg hsr hsn jur jun rtl rtp blk"
DNS_HOSTS=/tmp/hosts/soteria

WWW_DIR=/tmp/tinywww/
CRT_DIR=/tmp/tinycrt/

SRC_LIST="https://raw.githubusercontent.com/soteria-nou/domain-list/master/"

DNSMASQ_PIDFILE=/var/run/dnsmasq/dnsmasq.cfg01411c.pid
TINYSRV_PIDFILE=/var/run/tinysrv.pid

PIDOF=$(which pidof)

remove_file() {
  [ -f "$1" ] && rm "$1" || true
}

get_pid() {
  local _pid=
  [ -n "$2" ] && [ -f "$2" ] && kill -0 $(cat "$2") 2>/dev/null && _pid=$(cat "$2")
  [ -z "$_pid" ] && [ -x "$PIDOF" ] && _pid=$($PIDOF "$1")
  echo "$_pid"
}

kill_pid() {
  [ -n "$1" ] && for _i in $@; do kill "$_i" 2>/dev/null; done
}

hup() {
  [ -n "$1" ] || return 0
  kill -HUP "$1"
}

is_running() {
  [ ${#1} -gt 0 ] && return 0
  return 1
}

populate_dns_parts() {
  _ips=$(uci get network.soteria.ipaddr)
  [ $(echo "$_ips" | wc -w) -lt $(echo "$DNS_PARTS" | wc -w) ] && return 1
  for _dns_part in $DNS_PARTS; do
    _ip="${_ips%% *}"
    _ips="${_ips#* }"
    name=$(echo "$_dns_part" | tr "[a-z]" "[A-Z]")
    eval ${name}_IP="$_ip"
    [ "$_ip" = "$_ips" ] && break
  done
}

dnsmasq_pid() {
  get_pid dnsmasq "$DNSMASQ_PIDFILE"
}

dnsmasq_refresh() {
  PID=$(dnsmasq_pid)
  is_running "$PID" && hup "$PID"
}

tinysrv_pid() {
  get_pid "tinysrv" "$TINYSRV_PIDFILE"
}

stop_tinysrv() {
  kill_pid "$(tinysrv_pid)"
  remove_file "$TINYSRV_PIDFILE"
}

tinysrv_check() {
  PID=$(tinysrv_pid)
  is_running "$PID" && return 0
  [ -n "$TINYSRV_PIDFILE" ] || return 1
  [ -f "$TINYSRV_PIDFILE" ] && rm "$TINYSRV_PIDFILE"
  local _service=$(which tinysrv)
  [ -x "$_service" ] || return 0
  $_service -u nobody -P "$TINYSRV_PIDFILE" ${HSR_IP:+ -k 443 "$HSR_IP" -p 80 "$HSR_IP"} ${HSN_IP:+ -k 443 -R "$HSN_IP" -p 80 -R "$HSN_IP"} ${JUR_IP:+ -p 80 -c "$JUR_IP"} ${JUN_IP:+ -p 80 -c -R "$JUN_IP"}
}

hosts_append() {
  [ -n "$1" ] && [ -n "$2" ] || return 0
  local _url="${SRC_LIST%/}/$1"
  wget --no-check-certificate -q -O - "$_url" | sed "s/^/$2\t/"
}


hosts_update() {
  local _new_hosts="${DNS_HOSTS}_new"
  touch "$_new_hosts"
  chgrp dnsmasq "$_new_hosts"
  chmod 640 "$_new_hosts"
  hosts_append analytics.txt "$HSN_IP" >>"$_new_hosts"
  for _i in ads.txt affiliate.txt enrichments.txt fake.txt widgets.txt; do
    hosts_append $_i "$HSR_IP" >>"$_new_hosts"
  done
  if [ -s "$_new_hosts" ]; then
    >"$DNS_HOSTS"
    mv "$_new_hosts" "$DNS_HOSTS"
  fi
}

soteria_lock_file_create() {
  [ -n "$1" ] || return 1
  _lockfile=/tmp/.lock-soteria-$1
  [ -e "$_lockfile" ] && kill -0 $(cat $_lockfile) 2>/dev/null && return 1
  echo $$ >"$_lockfile"
  trap "rm -f $_lockfile; exit" INT TERM EXIT
  return 0
}

soteria_lock_file_destroy() {
  [ -n "$1" ] || return 1
  _lockfile=/tmp/.lock-soteria-$1
  rm -f "$_lockfile"
  trap - INT TERM EXIT
}

soteria_run() {
  soteria_lock_file_create libsoteria || return 1
  populate_dns_parts
  tinysrv_check
  hosts_update
  dnsmasq_refresh
  soteria_lock_file_destroy libsoteria
}