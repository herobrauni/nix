#!/usr/bin/env bash
# Monitor NixOS generation status across all fleet hosts.
# Usage: ./monitor.sh
set -euo pipefail

declare -A HOSTS=(
  [alpha1]=104.152.49.57
  [axushost1]=185.222.160.23
  [axushost2]=185.222.160.74
  [bero1]=5.180.253.70
  [crunchbits1]=104.36.84.254
  [deluxhost2]=31.56.7.40
  [gc1]=92.118.190.11
  [gc3]=92.118.190.37
  [gc5]=109.94.170.65
  [gigahost1]=185.125.169.63
  [hostsailor1]=185.183.98.121
  [hostc1]=2a0d:8142:0:20c::
  [hostc3]=2a0d:8142:0:2e::
  [hostc4]=2a0d:8142:0:fc::
  [nuyek1]=209.205.228.80
  [onidel1]=185.232.84.12
  [onidel2]=163.61.44.148
  [oracle1]=130.61.82.161
  [terabit1]=165.140.203.148
)

SSH_OPTS="-o ConnectTimeout=4 -o StrictHostKeyChecking=no -o BatchMode=yes"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

REMOTE_CMD=$(cat <<'REMOTE'
ts=$(stat -c %y /run/current-system 2>/dev/null | cut -d. -f1 || true)
gen=$(readlink /nix/var/nix/profiles/system 2>/dev/null | sed -n 's/.*system-\([0-9][0-9]*\)-link.*/\1/p')
rev=$(/run/current-system/sw/bin/nixos-version --configuration-revision 2>/dev/null || true)
if [[ "$rev" == *-dirty ]]; then
  rev="${rev:0:12}-dirty"
elif [[ -n "$rev" ]]; then
  rev="${rev:0:12}"
fi

[[ -n "$ts" ]] || ts="UNKNOWN"
[[ -n "$gen" ]] || gen="?"
[[ -n "$rev" ]] || rev="unknown"

printf "%s|%s|%s\n" "$ts" "$gen" "$rev"
REMOTE
)

for host in "${!HOSTS[@]}"; do
  ip="${HOSTS[$host]}"
  (
    ssh $SSH_OPTS brauni@"$ip" bash -s <<< "$REMOTE_CMD" > "$TMPDIR/$host" 2>/dev/null
  ) &
done
wait

printf "%-14s %-19s %-5s %s\n" "HOST" "LAST UPDATE" "GEN" "REV"
printf "%-14s %-19s %-5s %s\n" "────" "───────────" "───" "───"

sorted_hosts=$(printf '%s\n' "${!HOSTS[@]}" | sort)
for host in $sorted_hosts; do
  if [[ -s "$TMPDIR/$host" ]]; then
    IFS='|' read -r ts gen rev < "$TMPDIR/$host"
    printf "%-14s %-19s %-5s %s\n" "$host" "$ts" "$gen" "$rev"
  else
    printf "%-14s %-19s %-5s %s\n" "$host" "DOWN" "—" "—"
  fi
done
