#!/usr/bin/env bash
set -euo pipefail

# Read-only validation of a candidate Samsung SM-M146B kernel tree.
SOURCE_DIR="${1:-}"
EXPECTED_VERSION="${EXPECTED_KERNEL_VERSION:-5.15.211}"
if [[ -z "$SOURCE_DIR" || ! -f "$SOURCE_DIR/Makefile" ]]; then
  echo 'Usage: EXPECTED_KERNEL_VERSION=5.15.211 bash scripts/verify-source.sh /path/to/kernel' >&2
  exit 2
fi

read_make_value() {
  awk -F '=' -v key="$1" '$1 ~ "^[[:space:]]*" key "[[:space:]]*$" {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$SOURCE_DIR/Makefile"
}
version="$(read_make_value VERSION)"
patchlevel="$(read_make_value PATCHLEVEL)"
sublevel="$(read_make_value SUBLEVEL)"
actual="${version}.${patchlevel}.${sublevel}"
printf 'Source kernel version: %s\nExpected kernel version: %s\n' "$actual" "$EXPECTED_VERSION"
if [[ "$actual" != "$EXPECTED_VERSION" ]]; then
  echo 'STOP: source version does not match the required kernel base. Do not build or flash this as a matching kernel.' >&2
  exit 3
fi
printf 'Source base version matches; device firmware, vendor patches and boot compatibility remain UNVERIFIED.\n'
