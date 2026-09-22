# Samsung Galaxy M14 5G — Project-24 ReSukiSU update

**Target device:** `SM-M146B`, ReCoreUI 8.1 Ultra. **Existing kernel:** `5.15.211-android13-8@MrPankaj24`.

**Goal:** upgrade the kernel's *built-in ReSukiSU* while preserving the Project-24 device/vendor kernel changes and existing supported root/SUSFS features. This is **NOT a completed build or flashable ZIP**.

## Pinned upgrade target (checked 22 September 2026)

- Existing uploaded AnyKernel3 ZIP reports built-in `v4.2.0-rc2-6d18926a@ReSukiSU`.
- New integration source: [`ReSukiSU/ReSukiSU@9be0f347f38e790c846915bd5f9c24b337f85c4e`](https://github.com/ReSukiSU/ReSukiSU/commit/9be0f347f38e790c846915bd5f9c24b337f85c4e).
- GitHub compare shows this target **12 commits ahead** of `6d18926a`. This is a *development revision*, not a promise of a stable, tested release for SM-M146B. Examine [upstream changes](https://github.com/ReSukiSU/ReSukiSU/compare/6d18926a...9be0f347f38e790c846915bd5f9c24b337f85c4e) for compatibility.

**Do not confuse the Manager APK/ksud update with a kernel update.** A newly installed manager does not replace the ReSukiSU code compiled into the running kernel.

## Existing device evidence

- [`docs/DEVICE.md`](docs/DEVICE.md) — firmware and `uname -r` observed in Termux.
- [`docs/PROJECT24_ZIP_INSPECTION.md`](docs/PROJECT24_ZIP_INSPECTION.md) — archive inspection, compiled kernel string and embedded `.config` characteristics.
- User-uploaded ZIP is a prebuilt AnyKernel3 package with an `Image`, **not** the complete matching kernel source. Its installer disables device checking (`do.devicecheck=0`).
- A separate public [`MrPankaj24/SM-M146B-Kernel-Source`](https://github.com/MrPankaj24/SM-M146B-Kernel-Source) revision declares **5.15.153**, unlike the uploaded ZIP's **5.15.211**. The base release string alone would not prove the correct Samsung/Project-24 patches even if the number matched.

## Source-gated build workflow

On a **Linux PC**, after obtaining an exact source commit that contains the matching SM-M146B/Project-24 vendor changes:

```bash
export SOURCE_URL='https://github.com/REPLACE_WITH_VERIFIED_MATCHING_KERNEL.git'
export SOURCE_REF='REPLACE_WITH_VERIFIED_KERNEL_COMMIT'
export EXPECTED_KERNEL_VERSION='5.15.211'
export RESUKISU_SHA='9be0f347f38e790c846915bd5f9c24b337f85c4e'
bash scripts/prepare-kernel.sh
```

The script **stops on a mismatched base version** and checks that upstream ReSukiSU setup actually installed the pinned commit. It does not attempt to extract C source from a compiled `Image`.

Then restore the *matched* original defconfig (the user-provided `Image` embeds IKCONFIG), determine the source's precise Samsung toolchain/firmware build requirements, resolve all ReSukiSU and SUSFS patch conflicts, and inspect the resulting `.config` including `CONFIG_KSU=y`. Only when these conditions are met run:

```bash
bash scripts/build-image.sh
```

That command produces only a raw ARM64 `Image`, **not** a flashable Samsung boot image. Matching DTB/DTBO, vendor modules, exact boot partition format, backup/rollback and real-device testing are separate requirements. **Do not flash any output until verified.**

## Repository scripts

- [`scripts/device-info.sh`](scripts/device-info.sh): read-only device information.
- [`scripts/verify-source.sh`](scripts/verify-source.sh): rejects mismatched source versions.
- [`scripts/prepare-kernel.sh`](scripts/prepare-kernel.sh): pinned upstream checkout and integration, guarded by source checks.
- [`scripts/build-image.sh`](scripts/build-image.sh): guarded, un-packaged ARM64 kernel `Image` compilation.

No third-party kernel source or executable image has been published as a new build here. Preserve upstream copyright and licence notices and never publish personal backups, serial numbers, IMEIs, or private credentials.


## Build it yourself: start here

**[BUILD_FROM_SOURCE.md](docs/BUILD_FROM_SOURCE.md)** is the current source-first build plan. Run `bash scripts/kernel-preflight.sh /path/to/Project24-m14x-jaf1887.config` to audit the desired configuration. The candidate public M14 source is 5.15.153, not a proven match for the installed Project-24 5.15.211 kernel. We do not yet have matching source and rebuilt modules, so this repo has no independently built flashable release.
