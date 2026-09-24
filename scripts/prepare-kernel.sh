#!/usr/bin/env bash
set -euo pipefail

# Prepares sources on a Linux build PC. DOES NOT build or flash a kernel.
# Target updated 24 Sep 2026 from owner-provided Project-24 rc3 Image.
# Exact upstream SHA verified on GitHub; source integration and Samsung compatibility still untested.
: "${SOURCE_URL:?Set SOURCE_URL to the matching SM-M146B Project-24 kernel source Git URL}"
: "${SOURCE_REF:?Set SOURCE_REF to the verified kernel source commit SHA or immutable tag}"
RESUKISU_SHA="${RESUKISU_SHA:-6803643e19e2e6e8287f96461aabb93bdd6c47fa}"
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
