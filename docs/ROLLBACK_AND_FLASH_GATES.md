# JAF Kernel — rollback and flash readiness gates (SM-M146B)

**Status:** the experimental Image compiled successfully, with matching-release modules and matching device-tree blobs; this is NOT an on-phone boot test. The [offline report](https://github.com/jaf1887/my-project/actions/runs/35910680064) cannot certify the existing ROM's boot image, module installation paths, or recovery.

## Additional completed offline check

The extracted rebuilt module archive has exactly **300 module files** and **300 `modules.dep` entries**, referencing 135 distinct dependency targets; all referenced `.ko` paths exist within the same rebuilt archive (0 missing). This verifies the archive's *internal dependency paths*, **not** CRC/KMI compatibility with the ROM's vendor modules or successful runtime loading.

## 1. Read-only boot-partition backup on the owner's phone

The owner has previously shown this exact by-name partition map (recheck on-device first):

| By-name link | Previously observed target |
| --- | --- |
| boot | /dev/block/sda15 |
| init_boot | /dev/block/sda16 |
| vendor_boot | /dev/block/sda17 |
| dtbo | /dev/block/sda13 |
| recovery | /dev/block/sda18 |
| vbmeta | /dev/block/sda26 |
| vbmeta_system | /dev/block/sda27 |

**Do not hard-code the sdaN nodes into backup or restore procedures**: resolve by-name symlinks each time.

Review the [read-only backup helper](../scripts/backup-boot-partitions-termux.sh). It verifies SM-M146B and root permission; copies **only** the seven boot-related partitions above into a private Termux directory, hashes both the copy and original device, and stops if anything differs. It never writes to a block device. It **does write backup files to Termux storage** and requires adequate free space. It does not back up userdata or every part of the OS.

In Termux (inspect the downloaded script before running):

```bash
pkg install curl -y
curl -fsSLo "$HOME/jaf-backup.sh" \
  https://raw.githubusercontent.com/jaf1887/my-project/main/scripts/backup-boot-partitions-termux.sh
cat "$HOME/jaf-backup.sh"
bash "$HOME/jaf-backup.sh"
```

Before executing, charge the phone, reserve sufficient space and allow ReSukiSU root permission only if the script is what you expected. Do not interrupt a block-device read; any `.partial` copy is **invalid**. The output folder is private Termux storage and may be lost if Termux is removed, phone storage is wiped or the phone fails to boot.

**Copy the entire verified backup folder OFF the phone** using a method you control, ideally onto a trusted computer or encrypted external storage. Recheck `sha256sum -c SHA256SUMS` in the copied directory. Keep the original Project-24 ZIP and exact matching Samsung firmware available, and establish that you can access Download Mode and use a suitable restoration tool **before** any experimental flash. A backup without a verified restore route is not a recovery plan.

Backups may contain root, vendor boot and security configuration: **never upload `*.img` images to a public GitHub repo or send them into this chat**. Send only the script's text verification summary and partition sizes, omitting image bytes.

## 2. Read-only ROM module-location inspection

To determine how the current ROM actually loads the original 300 modules, collect only:

```bash
su -c 'cat /proc/modules | head -15'
su -c 'grep -E " (vendor|vendor_dlkm|odm_dlkm|system_dlkm) " /proc/mounts'
su -c 'find /vendor /vendor_dlkm /odm_dlkm /system_dlkm -type f -name "*.ko" 2>/dev/null | head -20'
```

An Image-only AnyKernel3 installer with `do.modules=0` **must not be used** for this new `@jaf1887` Image: the original module archive is labelled `@MrPankaj24`. Do not blindly copy `.ko` files into system or vendor, remount read-write, disable AVB, or patch vbmeta.

## 3. Packaging requirements

- Confirm the existing Project-24 installer actually patches only `boot`; it currently disables device checking. Do not reuse unchanged.
- Confirm exact module partition/load paths, module ABI/CRCs, and how the custom ROM mounts read-only dynamic partitions.
- Validate full boot header/ramdisk handling from the owner's backed-up existing `boot`, and preserve `init_boot` and `vendor_boot` unless an explicit, verified reason for updating them exists.
- Create an installer that **fails closed** unless model, SoC, partition identity, current kernel/ROM compatibility, backup acknowledgement and matching modules are present. Prefer an installer with an explicit rollback plan rather than claiming no-brick.
- Perform first boot and runtime hardware tests (display/touch, Wi-Fi, mobile network/SIM/calls/SMS, camera, audio, charging, encryption and root). Offline image strings/config cannot substitute for these.

**GO / NO-GO:** no flashable release until verified off-phone backups, recovery/restore route, correct module deployment plan, and reviewed installer. Never flash the raw GitHub Actions artifact.
