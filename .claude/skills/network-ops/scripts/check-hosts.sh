#!/usr/bin/env bash
# Check connectivity to all hosts in the network inventory

declare -A HOSTS=(
  [beelink]="192.168.1.137"
  [m2pro]="192.168.1.140"
  [nucbox]="192.168.1.31"
)

LOCAL_HOST=$(hostname)

for name in "${!HOSTS[@]}"; do
  ip="${HOSTS[$name]}"
  if [[ "$name" == "$LOCAL_HOST" ]]; then
    printf "%-10s %-16s %s\n" "$name" "$ip" "LOCAL"
    continue
  fi
  if ssh -o ConnectTimeout=3 -o BatchMode=yes "salim@${ip}" echo ok &>/dev/null; then
    printf "%-10s %-16s %s\n" "$name" "$ip" "OK"
  else
    printf "%-10s %-16s %s\n" "$name" "$ip" "UNREACHABLE"
  fi
done
