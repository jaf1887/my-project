# Device report — 22 September 2026

Source: device owner’s screenshots of read-only Termux commands. These record properties of the *running* configuration, not confirmation that any published source tree matches the installed kernel.

| Command | Observed output |
| --- | --- |
| `getprop ro.boot.em.model` | `SM-M146B` |
| `getprop ro.build.display.id` | `ReCoreUI 8.1.Ultra [BP2A.250605.031.A3.S711BXSFFZD2]` |
| `uname -r` | `5.15.211-android13-8@MrPankaj24` |
| `getprop ro.boot.bootloader` | `M146BXXSCDZB5` |
| `getprop ro.boot.hardware` | Appears as `verifiedbootstates5e8535` in screenshot; **ambiguous/unusual**, repeat this property before treating it as a clean SoC identifier. Other source/device-tree evidence identifies an `s5e8535` target, but the screenshot alone does not prove a normal hardware property value. |
| `getprop ro.boot.slot_suffix` | Empty output; **suggests** no reported A/B slot suffix, not a validated partition map. |
| `getprop ro.boot.verifiedbootstate` | `green`; **not proof** of a locked bootloader, given the custom ROM and root environment. |

**Bootloader evidence:** `M146BXXSCDZB5` is reported by the device; match the `M146B` model and bootloader/firmware family when selecting stock firmware or Samsung kernel source. The bootloader identifier alone does not specify the full source baseline.

**Important:** The display ID identifies a custom ROM and includes an `S711B`-like string; it is **not** the original stock Samsung M146B firmware identifier. Custom ROM properties may be spoofed; validate boot partitions using a read-only device-specific partition listing and original firmware package before packaging.

The browsed `MrPankaj24/SM-M146B-Kernel-Source` `Makefile` declares kernel `5.15.153`, not a demonstrated drop-in match for the running `5.15.211` Project-24 kernel. Need the matching 5.15.211 source, board defconfig, all modules, device trees and exact boot image layout.

No independently compiled flashable image, complete reproducible build or on-device tests have been produced by this repository.
