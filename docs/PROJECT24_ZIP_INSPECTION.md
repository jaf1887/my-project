# Project-24 m14x ReSukiSU ZIP inspection

Source: owner-supplied `Project24-Kernel-m14x-ReSukiSU (6).zip`, inspected without executing installer code or flashing anything.

- Archive SHA-256: `3a69dbf014449b23909f5ac00d7280bde06bf8151c8b33cbb2c7c9275c6ca6f9`
- ZIP integrity: passed (`ZipFile.testzip()` reported no corrupted member).
- Archive members: 19; main kernel payload is a 50,637,312-byte `Image` (SHA-256 `0f76f3d0409645356915096a6b6bd5049e9d01942a5fcbb72e11ffba5b9dfd5a`).
- `Image` has ARM64 `ARMd` magic in its header.
- Embedded Linux release: `5.15.211-android13-8@MrPankaj24`. This **matches the reported `uname -r` string**; it does not independently prove the currently installed bytes are identical.
- Embedded ReSukiSU version string: `v4.2.0-rc2-6d18926a@ReSukiSU`.
- SUSFS reports version `v2.3.0` in compiled-in diagnostic strings.
- Compiled kernel includes an embedded gzipped IKCONFIG (`IKCFG_ST`/`IKCFG_ED`), 236,966 bytes after decompression; SHA-256 `af842de9f958d7e95b0ae7d40af47e6bac0bd2d0f517e6edbe7909a54a178942`.
- Config has `CONFIG_ARM64=y`, `CONFIG_KSU=y`, `CONFIG_KSU_SUSFS=y`, `CONFIG_KSU_MULTI_MANAGER_SUPPORT=y`, `CONFIG_MODULES=y`, `CONFIG_OVERLAY_FS=y`, and `CONFIG_LOCALVERSION="@MrPankaj24"`.
- Installer is AnyKernel3 (`anykernel.sh`), sets `block=boot`, and invokes `split_boot` then either `write_boot` or `flash_boot`; it is **not** a standalone `boot.img`.
- The installer's `do.devicecheck=0` and empty device-name fields mean **the installer does not enforce SM-M146B compatibility**. Do not use it as evidence of safe compatibility with other devices.
- ZIP contains **no matching kernel source tree or toolchain**, so it cannot be used alone to recreate or edit the compiled kernel reproducibly. Embedded `.config` is valuable for selecting config once exact source is found.

No original ZIP or third-party executable binaries have been published in this repository, and nothing has been flashed. Verify source revision, vendor/ROM compatibility, modules, boot packaging and rollback before releasing any newly compiled replacement.
