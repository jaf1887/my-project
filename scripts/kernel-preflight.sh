#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:?Usage: bash scripts/kernel-preflight.sh PATH_TO_CONFIG}"
[[ -f "$CONFIG" ]] || { echo "Missing kernel config: $CONFIG" >&2; exit 2; }

check_enabled() {
  local key="$1"
  if grep -qxF "${key}=y" "$CONFIG"; then
    printf 'OK      %s=y\n' "$key"
  else
    printf 'MISSING %s=y\n' "$key"
    missing=1
  fi
}

missing=0
for key in CONFIG_ARM64 CONFIG_KSU CONFIG_KSU_SUSFS CONFIG_BBG CONFIG_MODULES CONFIG_MODVERSIONS; do
  check_enabled "$key"
done
if ! grep -qx 'CONFIG_LOCALVERSION="@jaf1887"' "$CONFIG"; then
  echo 'MISSING CONFIG_LOCALVERSION="@jaf1887"'
  missing=1
else
  echo 'OK      CONFIG_LOCALVERSION="@jaf1887"'
fi
if ! grep '^CONFIG_LSM=' "$CONFIG" | grep -q 'baseband_guard'; then
  echo 'MISSING baseband_guard in CONFIG_LSM'
  missing=1
else
  echo 'OK      baseband_guard registered'
fi
printf '\nDroidspaces feature gap (not automatically enabled; assess kABI first):\n'
for key in CONFIG_CGROUP_PIDS CONFIG_CGROUP_DEVICE CONFIG_BRIDGE_NETFILTER CONFIG_NF_TABLES; do
  if grep -qxF "${key}=y" "$CONFIG"; then
    printf 'YES     %s=y\n' "$key"
  else
    printf 'NO      %s=y\n' "$key"
  fi
done
if [[ "$missing" == 1 ]]; then
  echo 'STOP: build config is not yet the agreed jaf1887 target.' >&2
  exit 3
fi
echo 'Configuration passes these checks only. This does not verify source, ABI, bootability, or flash safety.'
