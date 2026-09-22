#!/usr/bin/env bash
set -euo pipefail

# Prepare a LOCAL kernel checkout; never touches a phone or produces a flashable image.
# Supply the exact matching source repository/ref and a reviewed ReSukiSU commit SHA.
: "${SOURCE_URL:?Set SOURCE_URL to a verified matching SM-M146B kernel source Git URL}"
: "${SOURCE_REF:?Set SOURCE_REF to an exact source commit SHA or immutable tag}"
: "${RESUKISU_SHA:?Set RESUKISU_SHA to a reviewed 40-hex-character upstream ReSukiSU commit SHA}"
EXPECTED_KERNEL_VERSION="${EXPECTED_KERNEL_VERSION:-5.15.211}"
WORKDIR="${WORKDIR:-$PWD/work}"
case "$RESUKISU_SHA" in
  *[!0-9a-fA-F]*|'') echo 'RESUKISU_SHA must be a full hexadecimal commit SHA' >&2; exit 2 ;;
esac
if [[ ${#RESUKISU_SHA} -ne 40 ]]; then echo 'RESUKISU_SHA must be 40 hex characters' >&2; exit 2; fi
mkdir -p "$WORKDIR"
if [[ -e "$WORKDIR/kernel" ]]; then echo "STOP: $WORKDIR/kernel already exists; use a fresh WORKDIR" >&2; exit 2; fi

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

# Upstream's documented integration script is reviewed/pinned by RESUKISU_SHA.
(cd "$WORKDIR/kernel" && bash "$WORKDIR/resukisu/kernel/setup.sh")
printf '\nReSukiSU integration script finished. Review changes, choose the proper SM-M146B defconfig and hooks, then build.\n'
printf 'NO kernel image has been built or validated for flashing.\n'
