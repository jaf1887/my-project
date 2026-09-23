#!/data/data/com.termux/files/usr/bin/bash
# JAF Kernel rollback backup for the owner's rooted SM-M146B.
# READS boot-related partitions into private Termux files. NEVER flashes.
set -euo pipefail

model="$(getprop ro.boot.em.model | tr -d '\r')"
[[ "$model" == "SM-M146B" ]] || {
  printf 'STOP: expected ro.boot.em.model=SM-M146B, got %q\n' "$model" >&2
  exit 2
}
[[ "$(su -c 'id -u' | tr -d '\r')" == "0" ]] || {
  echo 'STOP: root authorization is required for READ-ONLY backups.' >&2
  exit 2
}
# The path is interpolated in root's shell, so reject anything unexpected.
case "$HOME" in
  /data/data/com.termux/files/home|/data/user/0/com.termux/files/home) ;;
  *) echo "STOP: not a standard Termux HOME ($HOME)" >&2; exit 2 ;;
esac

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
dir="$HOME/jaf-rollback-$stamp"
mkdir -m 700 -- "$dir"
chmod 700 "$dir"
manifest="$dir/SHA256SUMS"
: > "$manifest"
printf '%s\n' "Device: $model" \
  "Bootloader: $(getprop ro.boot.bootloader)" \
  "Current kernel: $(uname -r)" \
  "Timestamp UTC: $stamp" > "$dir/device-info.txt"

echo "Read-only backups will be stored at: $dir"
df -h "$HOME"
echo 'STOP NOW if free space is insufficient. To cancel safely, press Ctrl+C.'
sleep 5

# Exact by-name links established from the owner's phone.
# DO NOT include EFS, modem, persist, keystore, userdata or super.
for part in boot init_boot vendor_boot dtbo recovery vbmeta vbmeta_system; do
  device="/dev/block/by-name/$part"
  image="$dir/$part.img"
  echo "BACKING UP: $part"
  su -c "test -b '$device'" || {
    echo "STOP: missing block partition $device" >&2
    exit 3
  }
  # A .partial file is never considered a valid backup. Output is a regular
  # file in private Termux storage, NOT another block device.
  su -c "dd if='$device' of='$image.partial' bs=1048576" || {
    echo "STOP: copying $part failed; keep existing backups." >&2
    exit 3
  }
  su -c "mv '$image.partial' '$image' && chown '$(id -u):$(id -g)' '$image' && chmod 600 '$image'"
  [[ -s "$image" ]] || {
    echo "STOP: empty backup $image" >&2
    exit 3
  }
  file_hash="$(sha256sum "$image" | awk '{print $1}')"
  device_hash="$(su -c "sha256sum '$device'" | awk '{print $1}')"
  if [[ -z "$device_hash" || "$device_hash" != "$file_hash" ]]; then
    echo "STOP: $part image hash differs from device; NOT verified." >&2
    exit 3
  fi
  printf '%s  %s\n' "$file_hash" "$part.img" >> "$manifest"
  echo "VERIFIED: $part ($(wc -c < "$image") bytes)"
done

( cd "$dir" && sha256sum -c SHA256SUMS )
chmod 600 "$manifest" "$dir/device-info.txt"
echo "SUCCESS: read-only partition images and hashes in $dir"
echo 'Copy this whole folder OFF THE PHONE using a trusted local method.'
echo 'Do not upload backups to GitHub, Telegram, or a public chat.'
echo 'No partition was written. This script is not a restore procedure.'
