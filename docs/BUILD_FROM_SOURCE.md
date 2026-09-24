# Build your own Galaxy M14 5G kernel — source-first

**Goal:** a genuinely rebuilt Project-24-compatible `SM-M146B` kernel labelled `@jaf1887`, with matching modules, ReSukiSU, SUSFS and Baseband-guard. Droidspaces support is a separate tested enhancement, not a default change.

## What we actually have

- Owner's three Project-24 AnyKernel3 ZIPs; [24 September audit](PROJECT24_2026-09-24_AUDIT.md) shows the latest image still reports `5.15.211-android13-8@MrPankaj24` but now ReSukiSU `v4.2.0-rc3-6803643e`.
- 169 DTB/DTBO files, 300 compiled modules (all tagged with the original `@MrPankaj24` release), and embedded original and edited `.config`.
- Public candidate Samsung/M14 source: [MrPankaj24/SM-M146B-Kernel-Source](https://github.com/MrPankaj24/SM-M146B-Kernel-Source), inspected at [93cf6da1a9efe090c79b487846d05d61104c6f5c](https://github.com/MrPankaj24/SM-M146B-Kernel-Source/commit/93cf6da1a9efe090c79b487846d05d61104c6f5c). It contains `arch/arm64/configs/s5e8535-m14xnsxx_defconfig` and the Exynos `s5e8535` / `m14x` device-tree work, but its `Makefile` declares **5.15.153**, NOT the matching final Project-24 5.15.211 tree. Samsung's source portal: https://opensource.samsung.com/.

**AOSP common 5.15.211 alone is not an M14 kernel:** the Samsung driver, board, device-tree, vendor and ABI modifications must be retained. Do not force-check out generic Linux 5.15.211 and combine it with the uploaded modules.

## Local developer setup (Linux PC; not Termux and not a phone flash)

1. Install Git, Python 3, a compatible Android Clang toolchain, make, and Samsung source-specific build dependencies. Check free disk/RAM before attempting a full Android kernel checkout.
2. Start from the 5.15.211 **devhunter1** Samsung source and `m14x_defconfig` identified through the original Project-24 Run128 workflow; see [SOURCE_AUDIT.md](SOURCE_AUDIT.md). Pin a real source commit and audit/port the workflow's Samsung, ReSukiSU, SUSFS, Baseband-guard and other patches. The exact source/recipe of the 24 Sep ZIP remains unverified; the public 5.15.153 release is a historical research baseline only.
3. Obtain the original source's build entrypoint, device defconfig, toolchain manifest, full stock firmware identifier and matching DTB/DTBO / module integration details.
4. Place the extracted edited configuration at a local path and run:

```bash
bash scripts/kernel-preflight.sh /path/to/Project24-m14x-jaf1887.config
```

This **only** audits selected settings. It cannot prove that features or a particular source build work.

## After a matching source revision is confirmed

```bash
export SOURCE_URL='https://github.com/REPLACE_WITH_VERIFIED_5.15.211_PROJECT24_SOURCE.git'
export SOURCE_REF='REPLACE_WITH_VERIFIED_FULL_SOURCE_COMMIT'
export EXPECTED_KERNEL_VERSION='5.15.211'
export RESUKISU_SHA='6803643e19e2e6e8287f96461aabb93bdd6c47fa'
bash scripts/prepare-kernel.sh
```

Do not run those placeholder values: they are a **stop gate**, not a build recipe. The verified devhunter1 5.15.211 source is a starting point but still needs the full audited integration workflow. If source already includes KernelSU/ReSukiSU, its existing integration must be reconciled before running the setup script (which might otherwise overwrite changes).

- Integrate/verify SUSFS patches **against that source's existing SUSFS baseline** and retain Baseband-guard's LSM integration. Both require review of source-level hook changes; a config flag alone is insufficient.
- Apply `CONFIG_LOCALVERSION="@jaf1887"` by running `bash scripts/set-kernel-localversion.sh work/out/.config` only on the resolved correct kernel config. Keep original contributor/author/copyright notices and GPL source obligations.
- Build using the **matching Samsung/Project-24 vendor build process**, including kernel `Image`, `s5e8535.dtb`, the correct `m14x` overlay(s), and all matching modules. The repo's generic `build-image.sh` is only an Image-stage development command, **not** the entire Samsung build and release procedure.
- The uploaded 300 old modules use `vermagic=5.15.211-android13-8@MrPankaj24`. A differently labelled kernel must **not** be distributed with those modules merely renamed. Rebuild compatible modules and verify modversion CRCs/KMI and runtime hardware.
- Validate recovery/rollback, image layout, model, boot, Wi-Fi, camera, audio, charging, cellular and runtime root features on the actual SM-M146B. Only then package AnyKernel3 with working model checks and publish a flashable artifact.

## Droidspaces is an optional second milestone

[Official guide](https://github.com/ravindu644/Droidspaces-OSS/blob/main/Documentation/Kernel-Configuration.md) warns that enabling GKI 5.15 namespace features may require kABI patches. Existing config lacks some features. Run its **on-phone requirements checker first**. Do not blindly enable missing flags in this build.

## Current honest state

- [x] User files inventoried; source candidates and device defconfig identified.
- [x] ReSukiSU target pinned and configuration preflight tested.
- [ ] Exact matching kernel source or independently ported, tested 5.15.211 Samsung source.
- [ ] Complete toolchain / reproducible compiled Image + modules + DTB/DTBO.
- [ ] On-device tests and independently validated flashable ZIP.

**No newly compiled binary or tested flashable ZIP exists yet.**
