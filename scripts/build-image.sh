#!/usr/bin/env bash
set -euo pipefail

# Builds only an un-packaged arm64 Image; NEVER flashes or releases a boot.img.
KERNEL_DIR="${KERNEL_DIR:-$PWD/work/kernel}"
OUT_DIR="${OUT_DIR:-$PWD/work/out}"
EXPECTED_KERNEL_VERSION="${EXPECTED_KERNEL_VERSION:-5.15.211}"
if [[ ! -f "$KERNEL_DIR/Makefile" ]]; then
  echo "Missing kernel source: $KERNEL_DIR. First use prepare-kernel.sh" >&2; exit 2
fi
EXPECTED_KERNEL_VERSION="$EXPECTED_KERNEL_VERSION" bash "$(dirname "$0")/verify-source.sh" "$KERNEL_DIR"
if ! command -v clang >/dev/null 2>&1; then
  echo 'Clang is required. Install the toolchain compatible with the exact Samsung kernel source.' >&2; exit 2
fi
if [[ ! -f "$OUT_DIR/.config" ]]; then
  echo "Missing $OUT_DIR/.config: configure the exact SM-M146B device/firmware defconfig before building." >&2; exit 2
fi
if ! grep -qx 'CONFIG_KSU=y' "$OUT_DIR/.config"; then
  echo 'CONFIG_KSU=y was not found in resolved .config; refusing to call this a ReSukiSU kernel.' >&2; exit 2
fi
if ! grep -qx 'CONFIG_KSU_SUSFS=y' "$OUT_DIR/.config"; then
  echo 'CONFIG_KSU_SUSFS=y was not found in resolved .config; SUSFS must remain enabled.' >&2; exit 2
fi
if ! grep -qx 'CONFIG_LOCALVERSION="@jaf1887"' "$OUT_DIR/.config"; then
  echo 'Custom build requires CONFIG_LOCALVERSION="@jaf1887"; run scripts/set-kernel-localversion.sh on the matching .config first.' >&2; exit 2
fi
if [[ ! -d "$KERNEL_DIR/KernelSU" && ! -d "$KERNEL_DIR/ksu" && ! -d "$KERNEL_DIR/drivers/kernelsu" ]]; then
  echo 'No expected integration directory found; verify the setup script result before building.' >&2
  exit 2
fi
mkdir -p "$OUT_DIR"
make -C "$KERNEL_DIR" O="$OUT_DIR" ARCH=arm64 LLVM=1 -j"$(nproc)" Image
if [[ ! -s "$OUT_DIR/arch/arm64/boot/Image" ]]; then
  echo 'Build completed without a non-empty ARM64 Image' >&2; exit 3
fi
sha256sum "$OUT_DIR/arch/arm64/boot/Image" > "$OUT_DIR/Image.sha256"
printf 'Kernel Image built: %s\nNOT flashable: device-specific DTB, vendor modules, packaging and device testing still required.\n' "$OUT_DIR/arch/arm64/boot/Image"
