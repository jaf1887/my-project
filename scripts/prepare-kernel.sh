#!/usr/bin/env bash
set -euo pipefail

# Prepares sources on a Linux build PC. DOES NOT build or flash a kernel.
# ReSukiSU target verified 22 Sep 2026: 12 commits after ZIP's 6d18926a base.
: "${SOURCE_URL:?Set SOURCE_URL to the matching SM-M146B Project-24 kernel source Git URL}"
: "${SOURCE_REF:?Set SOURCE_REF to the verified kernel source commit SHA or immutable tag}"
RESUKISU_SHA="${RESUKISU_SHA:-9be0f347f38e790c846915bd5f9c24b337f85c4e}"
EXPECTED_KERNEL_VERSION="${EXPECTED_KERNEL_VERSION:-5.15.211}"
WORKDIR="${WORKDIR:-$PWD/work}"

if [[ ! "$RESUKISU_SHA" =~ ^[[:xdigit:]]{40}$ ]]; then
  echo 'RESUKISU_SHA must be an exact 40-digit commit ID.' >&2
  exit 2
fi
mkdir -p "$WORKDIR"
if [[ -e "$WORKDIR/kernel" || -e "$WORKDIR/resukisu" ]]; then
  echo "STOP: $WORKDIR/kernel or $WORKDIR/resukisu exists. Use a fresh WORKDIR." >&2
  exit 2
fi

git clone --no-checkout "$SOURCE_URL" "$WORKDIR/kernel"
git -C "$WORKDIR/kernel" checkout --detach "$SOURCE_REF"
EXPECTED_KERNEL_VERSION="$EXPECTED_KERNEL_VERSION" bash "$(dirname "$0")/verify-source.sh" "$WORKDIR/kernel"

git clone https://github.com/ReSukiSU/ReSukiSU.git "$WORKDIR/resukisu"
git -C "$WORKDIR/resukisu" checkout --detach "$RESUKISU_SHA"
mkdir -p "$WORKDIR/reports"
{
  printf 'source_url=%s\n' "$SOURCE_URL"
  printf 'source_commit=%s\n' "$(git -C "$WORKDIR/kernel" rev-parse HEAD)"
  printf 'resukisu_commit=%s\n' "$(git -C "$WORKDIR/resukisu" rev-parse HEAD)"
  printf 'expected_kernel_version=%s\n' "$EXPECTED_KERNEL_VERSION"
} > "$WORKDIR/reports/provenance.txt"

# IMPORTANT: upstream setup.sh without an argument follows the MOVING main branch,
# even if the copy of setup.sh was checked out at a particular SHA. Pass the SHA.
(cd "$WORKDIR/kernel" && bash "$WORKDIR/resukisu/kernel/setup.sh" "$RESUKISU_SHA")

actual="$(git -C "$WORKDIR/kernel/KernelSU" rev-parse HEAD)"
if [[ "${actual,,}" != "${RESUKISU_SHA,,}" ]]; then
  echo "STOP: setup selected $actual, expected $RESUKISU_SHA" >&2
  exit 3
fi
printf 'Integrated ReSukiSU commit: %s\n' "$actual"
printf 'Integration completed. This is NOT a built kernel or flashable ZIP.\n'
printf 'Before compiling, resolve the EXACT device defconfig, Samsung vendor patches, toolchain and original boot image.\n'
