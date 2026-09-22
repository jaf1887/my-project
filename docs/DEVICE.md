# Device report — 22 September 2026

Source: device owner’s screenshot of read-only Termux commands. This records the *running* configuration only; it does not prove that any published source tree matches the installed kernel.

| Command | Observed output |
| --- | --- |
| `getprop ro.boot.em.model` | `SM-M146B` |
| `getprop ro.build.display.id` | `ReCoreUI 8.1.Ultra [BP2A.250605.031.A3.S711BXSFFZD2]` |
| `uname -r` | `5.15.211-android13-8@MrPankaj24` |
| `getprop ro.boot.bootloader` | `M146BXXSCDZB5` |

**Bootloader evidence:** `M146BXXSCDZB5` is the actual bootloader identifier reported by the device; match the `M146B` model and this bootloader/firmware family when finding an appropriate stock firmware and Samsung source release. Do **not** assume the custom-ROM display ID is the stock firmware build or that bootloader ID alone specifies the full kernel source baseline.

**Important:** The reported display ID identifies a custom ROM and includes an `S711B`-like string; it must **not** be taken as the original Samsung SM-M146B stock firmware identifier. Model properties may be modified in a custom ROM, although `ro.boot.em.model` is a stronger device clue than `ro.product.model`.

The publicly browsed `MrPankaj24/SM-M146B-Kernel-Source` `Makefile` previously showed a different `5.15.153` base; do not use it as a drop-in `5.15.211` build. Need the exact Project-24 source revision and build defconfig or a source release corresponding to this *running* kernel; original boot/vendor_boot (as applicable) and stock firmware metadata must be obtained and verified before boot-image packaging.

No flashable image, source-complete reproducible build, or on-device tests have been produced by this repository yet.
