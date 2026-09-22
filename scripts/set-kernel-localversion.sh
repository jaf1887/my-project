#!/usr/bin/env bash
set -euo pipefail

# Run on a Linux build PC AFTER restoring the correct Project-24 5.15.211
# source and device defconfig. Does not modify a compiled kernel or flash.
# Changing UTS_RELEASE also changes module/firmware lookup paths; matching
# modules must be rebuilt and verified before any release.

CONFIG_PATH="${1:-work/out/.config}"
TARGET='CONFIG_LOCALVERSION="@jaf1887"'

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "Missing config: $CONFIG_PATH" >&2
  exit 2
fi
if ! grep -q '^CONFIG_KSU=y$' "$CONFIG_PATH" || ! grep -q '^CONFIG_KSU_SUSFS=y$' "$CONFIG_PATH"; then
  echo 'Expected CONFIG_KSU=y and CONFIG_KSU_SUSFS=y in matching config.' >&2
  exit 2
fi
if ! grep -q '^CONFIG_LOCALVERSION=' "$CONFIG_PATH"; then
  echo 'No CONFIG_LOCALVERSION option found; refusing to silently append one.' >&2
  exit 2
fi
cp -- "$CONFIG_PATH" "$CONFIG_PATH.before-jaf1887"
sed -i -E 's/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION="@jaf1887"/' "$CONFIG_PATH"
grep -qxF "$TARGET" "$CONFIG_PATH"
printf 'Changed %s to %s; backup: %s.before-jaf1887\n' "$CONFIG_PATH" "$TARGET" "$CONFIG_PATH"
printf 'Source, original kernel author credits, licences, boot image and installed device are unchanged.\n'
