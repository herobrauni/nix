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
  [hostc5]=2a0d:8144:0:14f::
  [nuyek1]=209.205.228.80
  [onidel1]=185.232.84.12
  [onidel2]=163.61.44.148
  [oracle1]=130.61.82.161
  [ovh-nix1]=51.38.103.231
  [terabit1]=165.140.203.148
)

SSH_OPTS="-o ConnectTimeout=4 -o StrictHostKeyChecking=no -o BatchMode=yes"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

REMOTE_CMD=$(cat <<'REMOTE'
boot_ts=$(uptime -s 2>/dev/null | cut -d. -f1 || true)
gen=$(readlink /nix/var/nix/profiles/system 2>/dev/null | sed -n 's/.*system-\([0-9][0-9]*\)-link.*/\1/p')
rev=$(/run/current-system/sw/bin/nixos-version --configuration-revision 2>/dev/null || true)
# Get build time from the store path registration, not the boot-time symlink.
store_path=$(readlink -f /run/current-system 2>/dev/null || true)
build_ts="?"
if [[ -n "$store_path" && -x /run/current-system/sw/bin/nix ]]; then
  reg_time=$(nix path-info --json "$store_path" 2>/dev/null | grep -o '"registrationTime":[0-9]*' | head -1 | cut -d: -f2)
  if [[ -n "$reg_time" ]]; then
    build_ts=$(date -d "@$reg_time" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "$reg_time")
  fi
fi
if [[ "$rev" == *-dirty ]]; then
  rev="${rev:0:12}-dirty"
elif [[ -n "$rev" ]]; then
  rev="${rev:0:12}"
fi

[[ -n "$boot_ts" ]] || boot_ts="?"
[[ -n "$gen" ]] || gen="?"
[[ -n "$rev" ]] || rev="unknown"
[[ -n "$build_ts" ]] || build_ts="?"

printf "%s|%s|%s|%s\n" "$boot_ts" "$gen" "$rev" "$build_ts"
REMOTE
)

for host in "${!HOSTS[@]}"; do
  ip="${HOSTS[$host]}"
  (
    ssh $SSH_OPTS brauni@"$ip" bash -s <<< "$REMOTE_CMD" > "$TMPDIR/$host" 2>/dev/null
  ) &
done
wait

printf "%-14s %-19s %-5s %-19s %s\n" "HOST" "LAST BOOT" "GEN" "BUILT" "REV"
printf "%-14s %-19s %-5s %-19s %s\n" "────" "─────────" "───" "───────────" "───"

sorted_hosts=$(printf '%s\n' "${!HOSTS[@]}" | sort)
for host in $sorted_hosts; do
  if [[ -s "$TMPDIR/$host" ]]; then
    IFS='|' read -r boot_ts gen rev build_ts < "$TMPDIR/$host"
    printf "%-14s %-19s %-5s %-19s %s\n" "$host" "$boot_ts" "$gen" "$build_ts" "$rev"
  else
    printf "%-14s %-19s %-5s %-19s %s\n" "$host" "DOWN" "—" "—" "—"
  fi
done
