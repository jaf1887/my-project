# Project-24 newer build vs older build (22 September 2026)

Analysis of owner-provided original ZIPs, read as archives without executing installation scripts or flashing images.

| Field | Older ZIP (`Project24-Kernel-m14x-ReSukiSU (6).zip`) | Newer ZIP (`Project24-Kernel-m14x-ReSukiSU.zip`) |
| --- | --- | --- |
| ZIP SHA-256 | `3a69dbf014449b23909f5ac00d7280bde06bf8151c8b33cbb2c7c9275c6ca6f9` | `2e624126bb5213d32eec428f2b8aa4c173928dbffc353305adfb4afd9c9721e9` |
| Zip test | Passed | Passed |
| ARM64 `Image` size | 50,637,312 bytes | 50,633,216 bytes |
| `Image` SHA-256 | `0f76f3d0409645356915096a6b6bd5049e9d01942a5fcbb72e11ffba5b9dfd5a` | `95d6356883947ba438d2efbbfac3a5edb5de915fd64835aac8ba02b62d4617f9` |
| Embedded Linux release | `5.15.211-android13-8@MrPankaj24` | Same |
| Embedded ReSukiSU identifier | `v4.2.0-rc2-6d18926a@ReSukiSU` | `v4.2.0-rc2-9be0f347@ReSukiSU` |
| Embedded SUSFS version string | `v2.3.0` | `v2.3.0` |
| Embedded IKCONFIG SHA-256 | `af842de9f958d7e95b0ae7d40af47e6bac0bd2d0f517e6edbe7909a54a178942` | Same |
| Clang compiler from config | Ubuntu clang 22.1.8 | Same |
| ZIP member differences | — | **Only `Image` changed**. Installer, AnyKernel3 tools, banner and licence contents byte-identical. |

**Interpretation:** The newer package is a recompiled or replaced kernel `Image` carrying ReSukiSU commit `9be0f347`; it coincides with the specific upstream ReSukiSU commit previously selected for this repository's upgrade and is 12 upstream commits ahead of `6d18926a` by GitHub compare. The ReSukiSU version string provides strong evidence of that update, but a binary is not source-level proof of every patch applied. The newer package **does not show a numbered SUSFS upgrade**: both images report `v2.3.0`. Whether SUSFS received additional patches *within* v2.3.0 cannot be established from the same version string and identical `.config` alone; get source revision or a build changelog from the developer.

The unchanged configuration has `CONFIG_KSU=y`, `CONFIG_KSU_SUSFS=y`, `CONFIG_KSU_MULTI_MANAGER_SUPPORT=y`, `CONFIG_LTO_CLANG_FULL=y`. An unchanged `.config` means the feature selections are unchanged; it **does not** mean the compiled code is identical.

**Installer:** `anykernel.sh` was byte-identical across ZIPs; this did not change how the kernel is packaged or flashed. Both are AnyKernel3 ZIPs carrying a raw ARM64 `Image`, **not** standalone `boot.img` files and **not** complete kernel source. They do not establish compatibility with another phone or firmware. No image has been built, modified or flashed by this repository.

To produce an independent updated SUSFS + ReSukiSU kernel, obtain the matching Project-24 `5.15.211` source tree, vendor patches, SUSFS patch baseline and defconfig. If the owner's goal is *only* updating ReSukiSU to `9be0f347`, the uploaded newer ZIP already reports that identifier; do not represent our placeholder build scripts as another completed build.
