#!/bin/sh

DNS_PARTS="cfg hsr hsn jur jun rtl rtp blk"
WWW_DIR=/tmp/tinywww/
CRT_DIR=/tmp/tinycrt/

DNS_HOSTS=/tmp/dns
SRC_LIST="https://raw.githubusercontent.com/soteria-nou/domain-list/master/"

TINYSRV_PIDFILE=/var/run/tinysrv.pid
DNSMASQ_PIDFILE=/var/run/dnsmasq/dnsmasq.pid

get_pid() {
  local _pid
  [ -n "$2" ] && [ -f "$2" ] && kill -0 `cat "$2"` 2>/dev/null && _pid=`cat "$2"`
  [ -z "$_pid" ] && _pid=`pidof "$1"`
  echo "$_pid"
}

kill_pid() {
  [ -n "$1" ] && for _i in $@; do kill "$_i" 2>/dev/null; done
}

is_running() {
  [ ${#1} -gt 0 ] && return 0
  return 1
}

populate_dns_parts() {
  _ips=`uci get network.soteria.ipaddr`
  [ `echo "$_ips" | wc -w` -lt `echo "$DNS_PARTS" | wc -w` ] && return 1

  for _dns_part in $DNS_PARTS; do
    _ip="${_ips%% *}"
    _ips="${_ips#* }"
    eval `echo "$_dns_part" | tr "[a-z]" "[A-Z]"`_IP="$_ip"
  done

  return 0
}

dnsmasq_pid() {
  get_pid dnsmasq "$DNSMASQ_PIDFILE"
}

refresh_dnsmasq() {
  kill -HUP `dnsmasq_pid`
}

tinysrv_pid() {
  get_pid "tinysrv" "$TINYSRV_PIDFILE"
}

stop_tinysrv() {
  kill_pid "`tinysrv_pid`"
  remove_file "$TINYSRV_PIDFILE"
}

start_tinysrv() {
  is_running `tinysrv_pid` && stop_tinysrv
  [ -n "$TINYSRV_PIDFILE" ] || return 1
  [ -f "$TINYSRV_PIDFILE" ] && rm "$TINYSRV_PIDFILE"
  local _service=`which tinysrv`
  populate_dns_parts || return 0
  [ -x "$_service" ] || return 0
  [ -d "$WWW_DIR" ] || mkdir -p "$WWW_DIR"
  [ -d "$CRT_DIR" ] || mkdir -p "$CRT_DIR"
  $_service -u nobody -P $TINYSRV_PIDFILE -k 443 $HSR_IP -p 80 $HSR_IP -k 443 -R $HSN_IP -p 80 -R $HSN_IP -p 80 -c $JUR_IP -p 80 -c -R $JUN_IP -p 80 -S $WWW_DIR $RTL_IP ${CRT_DIR:+-p 443 -S $WWW_DIR -C $CRT_DIR $RTL_IP} && return 0
  return 1
}

append_hosts() {
  [ -n "$1" ] && [ -n "$2" ] || return 0
  wget --no-check-certificate -q -O - "${SRC_LIST%/}/$1" | sed "s/^/$2\t/" >>$DNS_HOSTS
}

update_hosts() {
  >$DNS_HOSTS
  populate_dns_parts
  append_hosts analytics.txt $HSN_IP
  for _i in ads.txt affiliate.txt enrichments.txt fake.txt widgets.txt; do
    append_hosts $_i $HSR_IP
  done
}

refresh_hosts() {
  update_hosts
  is_running `dnsmasq_pid` && refresh_dnsmasq
}
