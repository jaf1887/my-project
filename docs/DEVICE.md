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
| `su -c 'ls -l /dev/block/by-name/boot*'` | `/dev/block/by-name/boot -> /dev/block/sda15` |
| `su -c 'ls -l /dev/block/by-name/*dtb*'` | `/dev/block/by-name/dtbo -> /dev/block/sda13` |
| Full by-name listing: `init_boot` | `/dev/block/sda16` |
| Full by-name listing: `vendor_boot` | `/dev/block/sda17` |
| Full by-name listing: `recovery` | `/dev/block/sda18` |
| Full by-name listing: `vbmeta` | `/dev/block/sda26` |
| Full by-name listing: `vbmeta_system` | `/dev/block/sda27` |
| Full by-name listing: `super` | `/dev/block/sda32` |

**Bootloader evidence:** `M146BXXSCDZB5` is reported by the device; match the `M146B` model and bootloader/firmware family when selecting stock firmware or Samsung kernel source. The bootloader identifier alone does not specify the full source baseline.

**Important:** The display ID identifies a custom ROM and includes an `S711B`-like string; it is **not** the original stock Samsung M146B firmware identifier. Custom ROM properties may be spoofed; validate boot partitions using a read-only device-specific partition listing and original firmware package before packaging.

**Full read-only partition listing confirmed:** This phone has separate `boot`, `init_boot`, `vendor_boot`, `dtbo`, `recovery`, `vbmeta`, and `vbmeta_system` entries. These are links seen on **this** phone, not generic flash instructions. Never overwrite `init_boot`/`vendor_boot`/`dtbo` merely because they exist: the actual packaging requirements must come from the matching kernel source and the existing Project-24 installer. The uploaded original AnyKernel3 installer targets `boot`, but its compatibility checks are disabled; do not claim it is safe to reuse unchanged. Confirm image header format, backups, Samsung firmware, source revision and validated rollback before any write. Use partition names rather than fixed `/dev/block/sdaN` numbers in any future verified procedure.

The browsed `MrPankaj24/SM-M146B-Kernel-Source` `Makefile` declares kernel `5.15.153`, not a demonstrated drop-in match for the running `5.15.211` Project-24 kernel. Need the matching 5.15.211 source, board defconfig, all modules, device trees and exact boot image layout.

No independently compiled flashable image, complete reproducible build or on-device tests have been produced by this repository.
