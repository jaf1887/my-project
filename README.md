# Samsung Galaxy M14 5G (SM-M146B/DS) — ReSukiSU kernel project

A source-gated development workspace for creating an ARM64 ReSukiSU-enabled kernel for the **Samsung Galaxy M14 5G**. **No completed or flashable kernel is available yet.** The scripts operate on a PC/Linux build environment and do not modify the phone.

## What is implemented

- [`scripts/device-info.sh`](scripts/device-info.sh): read-only firmware/kernel report to run in Termux or `adb shell`.
- [`scripts/verify-source.sh`](scripts/verify-source.sh): rejects a mismatched kernel base version before integration/build.
- [`scripts/prepare-kernel.sh`](scripts/prepare-kernel.sh): checks out explicitly selected upstream kernel source and a pinned ReSukiSU commit, records provenance, and invokes ReSukiSU's integration script **only after** the source version matches.
- [`scripts/build-image.sh`](scripts/build-image.sh): guarded ARM64 `Image` compilation after a device-specific `.config` and proper Clang toolchain are supplied. It does **not** package a Samsung boot image or claim that the result boots.

## Important current source mismatch

A previously reported working Project-24 kernel on this device has release **5.15.211-android13-8**. At inspection, the `Makefile` in [`MrPankaj24/SM-M146B-Kernel-Source`](https://github.com/MrPankaj24/SM-M146B-Kernel-Source) declares **5.15.153**, so it cannot be treated as an exact replacement for that installed kernel without locating the correct revision or reconciling the vendor and Project-24 patches. ReSukiSU upstream: <https://github.com/ReSukiSU/ReSukiSU>. The exact current phone firmware build and device-specific build configuration are still needed.

## Obtain the read-only phone report

Copy `scripts/device-info.sh` onto the phone and run `sh device-info.sh` in Termux, or run the equivalent `getprop` and `uname` commands via `adb shell`. Review output before sharing it publicly.

## Prepare an explicitly verified source checkout

Run these commands **on a Linux build PC**, only after choosing the correct source and reviewing the integration script. The SHA must be the exact 40-character commit ID you intend to use:

```bash
export SOURCE_URL='https://github.com/REPLACE_WITH_VERIFIED_MATCHING_KERNEL.git'
export SOURCE_REF='REPLACE_WITH_VERIFIED_KERNEL_COMMIT'
export RESUKISU_SHA='REPLACE_WITH_REVIEWED_40_CHARACTER_RESUKISU_COMMIT'
export EXPECTED_KERNEL_VERSION='5.15.211'
bash scripts/prepare-kernel.sh
```

The preparation script deliberately refuses to build from a `5.15.153` tree when `5.15.211` is required. **Do not defeat this check simply to produce an image.**

## Build after device configuration is verified

A correct Samsung/Project-24 device defconfig must first be resolved into `work/out/.config`, containing `CONFIG_KSU=y`, and the compatible Android Clang toolchain must be on `PATH`. Only then:

```bash
bash scripts/build-image.sh
```

This is a generic `Image` build stage, not a substitute for the upstream vendor build process. A successful `Image` alone is **not flashable**; the matching DTB/DTBO, modules, boot-image layout, firmware and rollback method must be verified separately. No GitHub Action is configured to flash or distribute untested output.

See [`docs/BUILD_PLAN.md`](docs/BUILD_PLAN.md) for validation gates. Never publish IMEI, serial numbers, personal phone backups or private credentials. Preserve upstream copyright and licence notices when importing code.
