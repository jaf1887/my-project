# JAF Kernel — Samsung Galaxy M14 5G

**Target device:** `SM-M146B`, ReCoreUI 8.1 Ultra. **Existing kernel:** `5.15.211-android13-8@MrPankaj24`.

**Goal:** compile an independently built `5.15.211-android13-8@jaf1887` Samsung Galaxy M14 5G kernel, rebuilding matching modules and retaining compatible ReSukiSU, SUSFS and Baseband-guard features. This is **NOT a completed build or flashable ZIP**.

## Pinned integration reference (updated 24 September 2026)

- Oldest uploaded Image reported `v4.2.0-rc2-6d18926a@ReSukiSU`; the next reported `v4.2.0-rc2-9be0f347@ReSukiSU`.
- The [24 September 2026 uploaded ZIP audit](docs/PROJECT24_2026-09-24_AUDIT.md) confirms the latest Image reports **`v4.2.0-rc3-6803643e@ReSukiSU`** and still uses `5.15.211-android13-8@MrPankaj24`.
- Current pinned ReSukiSU integration reference: [`6803643e19e2e6e8287f96461aabb93bdd6c47fa`](https://github.com/ReSukiSU/ReSukiSU/commit/6803643e19e2e6e8287f96461aabb93bdd6c47fa). This pin is not proof of tested JAF compatibility.

**Do not confuse the Manager APK/ksud update with a kernel update.** A newly installed manager does not replace the ReSukiSU code compiled into the running kernel.

## Existing device evidence

- [`docs/DEVICE.md`](docs/DEVICE.md) — firmware and `uname -r` observed in Termux.
- [`docs/PROJECT24_ZIP_INSPECTION.md`](docs/PROJECT24_ZIP_INSPECTION.md) — archive inspection, compiled kernel string and embedded `.config` characteristics.
- User-uploaded ZIP is a prebuilt AnyKernel3 package with an `Image`, **not** the complete matching kernel source. Its installer disables device checking (`do.devicecheck=0`).
- A separate public [`MrPankaj24/SM-M146B-Kernel-Source`](https://github.com/MrPankaj24/SM-M146B-Kernel-Source) revision declares **5.15.153**, unlike the uploaded ZIP's **5.15.211**. See [SOURCE_AUDIT.md](docs/SOURCE_AUDIT.md) for the **devhunter1** 5.15.211 tree identified from the original Project-24 Run128 workflow; matching the September 24 binary to an exact source revision is still pending.

## Source-gated build workflow

On a **Linux PC**, after obtaining an exact source commit that contains the matching SM-M146B/Project-24 vendor changes:

```bash
export SOURCE_URL='https://github.com/REPLACE_WITH_VERIFIED_MATCHING_KERNEL.git'
export SOURCE_REF='REPLACE_WITH_VERIFIED_KERNEL_COMMIT'
export EXPECTED_KERNEL_VERSION='5.15.211'
export RESUKISU_SHA='6803643e19e2e6e8287f96461aabb93bdd6c47fa'
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


## Source discovery update (22 September 2026)

The newly located [5.15.209 Samsung Exynos source](https://github.com/MrPankaj24/android_kernel_samsung_s5e8535) is closer to the running version than the [M14-specific 5.15.153 source](https://github.com/MrPankaj24/SM-M146B-Kernel-Source), but neither has been verified as the complete 5.15.211 Project-24 source. See the [source audit](docs/SOURCE_AUDIT.md) before attempting a build. Do not edit `SUBLEVEL` to mask a mismatch.


## Cloud build workflows

- [GitHub Actions instructions](docs/GITHUB_ACTIONS.md)
- [Kernel CI validation](.github/workflows/kernel-ci.yml)
- [Experimental source-gated Image/modules build](.github/workflows/build-kernel.yml)
- [Add extracted configuration](configs/README.md)

The experimental workflow now uses a pinned observed **devhunter1 5.15.211** source revision, but does **not** reproduce the original Project-24 patch workflow or establish that its output is compatible with the September 24 uploaded image. Do not treat an Actions artifact as flashable without matching source/modules and on-device testing.


## Active next step — Run130 pinned integration attempt

The new [Run130-pinned experimental GitHub Actions workflow](.github/workflows/jaf-run130-pinned.yml) uses the identified devhunter1 5.15.211 Samsung source, pinned ReSukiSU RC3, SUSFS, Baseband-guard and the Exynos 1330 Droidspaces patch. It **attempts** to build a raw Image with newly built modules and DTBs while preserving compiler and patch logs. It does **not** flash, publish a release, or claim to reproduce all of Pankaj's optimization patches. Read [Run130 build instructions](docs/GITHUB_ACTIONS.md#c-new-run130-pinned-experimental-source-integration-and-compilation). Its output is not flashable or known bootable; first fix any failed source integration / build errors, then review ABI and real-device testing before package work.
