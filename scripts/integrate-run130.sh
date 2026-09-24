#!/usr/bin/env bash
set -euo pipefail

# Source integration for an EXPERIMENTAL, non-flashable JAF Kernel Image.
# Derived from the owner-supplied Project-24 Run130 build recipe; source refs
# are pinned. Do not replace the original Samsung vendor source with AOSP GKI.
KERNEL_DIR="${1:-kernel-src}"
KERNEL_DIR="$(cd "$KERNEL_DIR" && pwd)"
EXPECTED_SOURCE_SHA="${EXPECTED_SOURCE_SHA:-906601a25962356b037817ed5deaa483b44b9233}"
RESUKISU_SHA="${RESUKISU_SHA:-6803643e19e2e6e8287f96461aabb93bdd6c47fa}"
SUSFS_SHA="${SUSFS_SHA:-7af04b08f86a5f811cbea28805f96d52368e005f}"
PATCHES_SHA="${PATCHES_SHA:-82c26549197e0288167514c4054e503049bc1051}"
BBG_SHA="${BBG_SHA:-a54e0dc6cf0aff4dd87fec49644a02d2eb612905}"
JAF_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() { echo "STOP: $*" >&2; exit 3; }
check_sha() {
  [[ "$1" =~ ^[0-9a-fA-F]{40}$ ]] || die "Not a full source SHA: $1"
}
for sha in "$EXPECTED_SOURCE_SHA" "$RESUKISU_SHA" "$SUSFS_SHA" "$PATCHES_SHA" "$BBG_SHA"; do check_sha "$sha"; done
[[ "$(git -C "$KERNEL_DIR" rev-parse HEAD)" == "$EXPECTED_SOURCE_SHA" ]] ||
  die "Samsung source SHA differs from the reviewed snapshot."
EXPECTED_KERNEL_VERSION=5.15.211 bash "$JAF_REPO_ROOT/scripts/verify-source.sh" "$KERNEL_DIR"
[[ -f "$KERNEL_DIR/arch/arm64/configs/m14x_defconfig" ]] || die 'm14x_defconfig absent'
for p in KernelSU susfs_repo patch_repo Baseband-guard; do
  [[ ! -e "$KERNEL_DIR/$p" && ! -L "$KERNEL_DIR/$p" ]] ||
    die "$KERNEL_DIR/$p already exists; start from a fresh source checkout"
done

clone_pinned() {
  local url="$1" dest="$2" sha="$3"
  git clone --filter=blob:none "$url" "$KERNEL_DIR/$dest"
  git -C "$KERNEL_DIR/$dest" checkout --detach "$sha"
  [[ "$(git -C "$KERNEL_DIR/$dest" rev-parse HEAD)" == "$sha" ]] || die "$dest checkout mismatch"
}
clone_pinned https://github.com/ReSukiSU/ReSukiSU.git KernelSU "$RESUKISU_SHA"
clone_pinned https://gitlab.com/simonpunk/susfs4ksu.git susfs_repo "$SUSFS_SHA"
clone_pinned https://github.com/MrPankaj24/kernel_patch.git patch_repo "$PATCHES_SHA"
clone_pinned https://github.com/vc-teahouse/Baseband-guard.git Baseband-guard "$BBG_SHA"

cd "$KERNEL_DIR"
[[ ! -e drivers/kernelsu && ! -L drivers/kernelsu ]] ||
  die 'drivers/kernelsu already exists'
ln -s ../KernelSU/kernel drivers/kernelsu
grep -qF 'obj-$(CONFIG_KSU) += kernelsu/' drivers/Makefile ||
  printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> drivers/Makefile
grep -qF 'source "drivers/kernelsu/Kconfig"' drivers/Kconfig ||
  printf '\nsource "drivers/kernelsu/Kconfig"\n' >> drivers/Kconfig
[[ -f KernelSU/kernel/Kconfig ]] || die 'ReSukiSU Kconfig missing'

# Upstream SUSFS files and the two Run130 source-level patches. NEVER mask
# rejected hunks, clear *.rej, or claim success if either patch fails.
cp susfs_repo/kernel_patches/fs/susfs.c fs/
cp susfs_repo/kernel_patches/include/linux/susfs_def.h include/linux/
cp susfs_repo/kernel_patches/include/linux/susfs.h include/linux/
# Preserve complete output and rejected hunks as downloadable Actions evidence.
# Do not stop at the first "FAILED" message without preserving WHY it failed.
mkdir -p "$JAF_REPO_ROOT/work/reports"
capture_patch_failure() {
  local label="$1"
  local report="$JAF_REPO_ROOT/work/reports"
  printf '\nSTOP: %s contains rejected source hunks.\n' "$label" >&2
  echo 'Rejected files:' >&2
  find fs include kernel security -type f -name '*.rej' -print 2>/dev/null | tee "$report/rejected-files.txt" >&2 || true
  if [[ -s "$report/rejected-files.txt" ]]; then
    # Preserve relative source paths within the archive. Partial patch state
    # must never be used for compilation or treated as a valid release.
    tar -czf "$report/rejected-hunks.tar.gz" -T "$report/rejected-files.txt" ||
      echo 'Could not archive all reject files' >&2
    for rejected in $(cat "$report/rejected-files.txt"); do
      if [[ "$rejected" == 'fs/namespace.c.rej' ]]; then
        cp "$rejected" "$report/fs-namespace.rej.txt"
      fi
    done
  fi
  printf '%s\n' \
    'Upstream 50 patch may only partially fit this pinned devhunter1 revision.' \
    'Do NOT skip these hooks or delete rejects: inspect the .rej files and port the missing code.' >&2
  exit 3
}
# Run #2 proved that 51 supplies the Samsung replacements for four header
# hunks in 50. Prepare that composition before patching; never tolerate rejects.
python3 "$JAF_REPO_ROOT/scripts/prepare-run130-susfs.py" \
  susfs_repo/kernel_patches/50_add_susfs_in_gki-android13-5.15.patch \
  patch_repo/for_devhunter1/51_susfs_fix.patch \
  "$JAF_REPO_ROOT/work/reports/susfs-50-prepared.patch"
if ! patch --batch --forward -p1 < "$JAF_REPO_ROOT/work/reports/susfs-50-prepared.patch" \
     > "$JAF_REPO_ROOT/work/reports/susfs-50-patch.log" 2>&1; then
  cat "$JAF_REPO_ROOT/work/reports/susfs-50-patch.log" >&2
  capture_patch_failure 'SUSFS 50'
fi
if ! patch --batch --forward -p1 < patch_repo/for_devhunter1/51_susfs_fix.patch \
     > "$JAF_REPO_ROOT/work/reports/susfs-51-patch.log" 2>&1; then
  cat "$JAF_REPO_ROOT/work/reports/susfs-51-patch.log" >&2
  capture_patch_failure 'Project-24 SUSFS 51'
fi

# BBG: integrate the *pinned* tree without curl | bash or a moving main.
ln -s ../Baseband-guard security/baseband-guard
grep -qF 'obj-$(CONFIG_BBG) += baseband-guard/' security/Makefile ||
  printf '\nobj-$(CONFIG_BBG) += baseband-guard/\n' >> security/Makefile
grep -qF 'source "security/baseband-guard/Kconfig"' security/Kconfig ||
  printf '\nsource "security/baseband-guard/Kconfig"\n' >> security/Kconfig

# Run130 has Droidspaces enabled by default. Apply the pinned 1330 patch,
# but DO NOT independently enable GKI ABI-sensitive configs without review.
patch --batch --forward -p1 < patch_repo/Droidspace/droidspace_for_1330.patch ||
  die 'Droidspaces 1330 patch conflict: source needs manual review'

# Stop on unresolved patch rejects and record precise input provenance.
if find . -name '*.rej' -print -quit | grep -q .; then
  die 'Patch reject files exist; integration is incomplete.'
fi
mkdir -p "$JAF_REPO_ROOT/work/reports"
{
  printf 'source_commit=%s\n' "$EXPECTED_SOURCE_SHA"
  printf 'resukisu_commit=%s\n' "$(git -C KernelSU rev-parse HEAD)"
  printf 'susfs_commit=%s\n' "$(git -C susfs_repo rev-parse HEAD)"
  printf 'project24_patches_commit=%s\n' "$(git -C patch_repo rev-parse HEAD)"
  printf 'baseband_guard_commit=%s\n' "$(git -C Baseband-guard rev-parse HEAD)"
  printf 'recipe=Project-24 Run130 (selected pinned features; not full reproduction)\n'
} > "$JAF_REPO_ROOT/work/reports/run130-inputs.txt"
echo "Pinned source integration completed. Compile/test Image and matching modules; DO NOT FLASH."
