# Project-24 DTB and module compatibility audit

Two owner-uploaded archive files were inspected as read-only ZIPs on 22 September 2026. ZIP integrity test passed for both.

## DTBs — `Project24-DTBs-m14x.zip`

- SHA-256: `c596fed1a3b4bb1b10d4fd72e1b0e73f334e58dd7311d8b05f2961aca6b6340e`.
- 169 flat device-tree files under `dtb_files/` (not a compiled kernel source tree and not a boot-image installer).
- Contains `s5e8535.dtb` and M14 overlay candidates `m14x_eur_open_w00_r00.dtbo`, `m14x_eur_open_w00_r01.dtbo`, `m14x_eur_open_w00_r03.dtbo`, as well as A14 and other chipset files.
- Inspected `s5e8535.dtb` and `m14x_eur_open_w00_r00.dtbo` show expected flattened-device-tree magic `d00dfeed`, but magic alone is not proof they match the exact phone, board revision, ROM or packaging requirements.
- Do **not** concatenate all DTBs/DTBOs or flash them blindly. Determine the required board and boot format first.

## Modules — `Project24-Modules-m14x-ReSukiSU.zip`

- SHA-256: `820213af06b811736fc4805dcf19312320561e9c12aca4e029503e5bc78ff07f`.
- 300 compiled `.ko` modules and dependency/index metadata. Not a kernel source tree and no standalone AnyKernel3 `update-binary` installer.
- All 300 compiled modules advertise `vermagic=5.15.211-android13-8@MrPankaj24 SMP preempt mod_unload modversions aarch64`.
- All files reside beneath `lib/modules/5.15.211-android13-8@MrPankaj24/`.
- Example modules include camera (`fimc-is.ko`), Wi-Fi (`scsc_wlan.ko`), GPU/display and battery drivers.

## Critical implication for the requested rename

`@jaf1887` changes kernel release identity. Renaming module **paths** alone does not update `.ko` ELF `vermagic` or ensure module ABI/CRC compatibility. Attempting to use these original modules with a rebuilt `5.15.211-android13-8@jaf1887` kernel may make camera, Wi-Fi, touchscreen, display, modem or other subsystems fail, or cause boot failure. **Rebuild compatible modules from the matching Project-24 5.15.211 source alongside the kernel**; preserve exact kernel release and ABI where required.

The prebuilt newer Project-24 `Image` already includes ReSukiSU `9be0f347` and still reports `5.15.211-android13-8@MrPankaj24`. Its existing AnyKernel3 ZIP can be treated as the **original publisher's package**, not as a new `@jaf1887` or newly SUSFS-patched build. No new flashable image can be validated from these three compiled archives alone.

**Do not modify/redistribute original kernel authorship or licence credits as if these binaries were rebuilt by jaf1887.**
