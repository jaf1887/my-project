#!/usr/bin/env bash
# Static checks only. Never substitutes for testing on the actual SM-M146B.
set -euo pipefail

if [[ "$#" -ne 3 ]]; then
  echo "Usage: bash scripts/validate-compiled-kernel.sh OUT_DIR MODULES_INSTALL_DIR EXPECTED_KERNELRELEASE" >&2
  exit 2
fi

OUT_DIR="$1"
MODULES_DIR="$2"
EXPECTED="$3"
IMAGE="$OUT_DIR/arch/arm64/boot/Image"
CONFIG="$OUT_DIR/.config"

[[ "$EXPECTED" == '5.15.211-android13-8@jaf1887' ]] || {
  echo "Unexpected kernel release: $EXPECTED" >&2; exit 3;
}
[[ -s "$IMAGE" && -s "$CONFIG" ]] || {
  echo 'Image or final .config missing' >&2; exit 3;
}
image_size="$(stat -c '%s' "$IMAGE")"
if (( image_size < 20000000 || image_size > 120000000 )); then
  echo "Suspicious ARM64 Image size: $image_size" >&2
  exit 3
fi

for line in 'CONFIG_LOCALVERSION="@jaf1887"' \
            'CONFIG_MODULES=y' \
            'CONFIG_MODVERSIONS=y' \
            'CONFIG_KSU=y' \
            'CONFIG_KSU_SUSFS=y' \
            'CONFIG_BBG=y'; do
  grep -qxF "$line" "$CONFIG" || {
    echo "Missing $line" >&2; exit 3;
  }
done
grep '^CONFIG_LSM=' "$CONFIG" | grep -q 'baseband_guard' || {
  echo 'Baseband-guard missing from CONFIG_LSM' >&2; exit 3;
}

modpath="$MODULES_DIR/lib/modules/$EXPECTED"
[[ -d "$modpath" ]] || {
  echo "Matching modules directory missing: $modpath" >&2; exit 3;
}
command -v modinfo >/dev/null || {
  echo 'modinfo missing; install kmod' >&2; exit 3;
}
count=0
while IFS= read -r -d '' ko; do
  actual="$(modinfo -F vermagic "$ko")"
  if [[ "${actual%% *}" != "$EXPECTED" ]]; then
    echo "Mismatched module $ko: $actual" >&2
    exit 3
  fi
  ((count += 1))
done < <(find "$modpath" -type f -name '*.ko' -print0)
(( count > 0 )) || {
  echo 'No matching modules were compiled' >&2; exit 3;
}

dts="$OUT_DIR/arch/arm64/boot/dts"
[[ -d "$dts" ]] || { echo 'Missing device-tree output' >&2; exit 3; }
find "$dts" -type f -name 's5e8535.dtb' | grep -q . || {
  echo 'Missing SoC s5e8535.dtb' >&2; exit 3;
}
find "$dts" -type f -name '*m14x*.dtbo' | grep -q . || {
  echo 'Missing M14-specific DTBO(s)' >&2; exit 3;
}
echo "PASS static checks: Image ${image_size} bytes; ${count} modules with matching vermagic; DTS output present."
echo 'NOT TESTED: boot.img format, module CRCs/KMI, runtime drivers, cellular, Wi-Fi, camera, SELinux, or bootability.'
