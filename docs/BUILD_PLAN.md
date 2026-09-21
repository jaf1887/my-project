# Kernel build and validation plan

This is a development checklist, **not** a verified flashing guide. Do not assume an image is compatible merely because it boots on another M14 model or firmware.

## 1. Record the device and current software

- Exact model code from **Settings → About phone** (for example, do not substitute a similarly named M14 variant).
- Full **Build number**, **baseband**, Android and One UI versions.
- Current kernel version and build identifier from **Settings → About phone → Software information** or an appropriate local read-only command.
- SoC and boot image format, determined from verified sources for this exact model.
- Current root manager version and the exact Resuki SU project/revision to integrate.

Never publish serial numbers, IMEI, account information, personal backups or proprietary firmware extracted from another device.

## 2. Establish trusted sources

1. Obtain the Samsung kernel source release matching the device and firmware family. Record its release URL, version, hash and licence notices.
2. Identify the **correct** Resuki SU upstream and its supported kernel versions. Record upstream URL, pinned commit/tag, dependencies and licence.
3. Confirm the exact device-tree, defconfig, toolchain and image packaging requirements from the matching source/documentation.
4. Keep vendor-provided blobs or other materials out of the repository unless their redistribution terms explicitly allow it.

## 3. Prepare a reproducible build

- Pin toolchain and build dependencies by version.
- Preserve upstream source and add small, reviewable patches.
- Log the build command, defconfig, git commit, output filenames and SHA-256 digests.
- Do not claim Resuki SU integration until the relevant build configuration and running-device result have both been verified.

## 4. Validation gates before any release

- [ ] Exact model and firmware recorded
- [ ] Matching source and licence checked
- [ ] Resuki SU upstream and compatibility checked
- [ ] Clean build succeeds
- [ ] Boot image packaging verified for this model
- [ ] Recovery and rollback method tested independently
- [ ] Owner has a complete backup
- [ ] Boot, storage, Wi-Fi, mobile network, audio, camera and charging tested
- [ ] Root functionality tested on the running kernel
- [ ] Known issues and reproducible build instructions documented

A green build is **not** evidence that an image is safe to flash. Never publish a "flashable" release without device-specific testing.
