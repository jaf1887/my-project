# Source audit — JAF Kernel SM-M146B (22 September 2026)

The **current running image** is `5.15.211-android13-8@MrPankaj24`. A source tree that simply contains an M14 device tree is **not** automatically a matching reproduction of that image.

## Verified public candidates

| Repository | Inspected branch | Makefile base | M14 information | Verdict |
| --- | --- | --- | --- | --- |
| [MrPankaj24/SM-M146B-Kernel-Source](https://github.com/MrPankaj24/SM-M146B-Kernel-Source) | `main` | **5.15.153** | `arch/arm64/configs/s5e8535-m14xnsxx_defconfig`, Exynos `s5e8535.dtb`, M14 device trees | **Device-specific candidate**, but not the matching 5.15.211 source. |
| [MrPankaj24/android_kernel_samsung_s5e8535](https://github.com/MrPankaj24/android_kernel_samsung_s5e8535) | `lineage-23.2` | **5.15.209** | Includes `arch/arm64/boot/dts/samsung/m14x/m14x_eur_open_w00_r00.dts` and Exynos DTS; has a `build_kernel.sh` referencing Clang `r450784d` and `TARGET_SOC=s5e8535`. The named M14 defconfig path from the other repo is **not present at that path**. | **Closer base number, not proved to be this device's compiled Project-24 source/configuration.** |
| [Linux stable 5.15.211](https://www.kernel.org/pub/linux/kernel/v5.x/) | stable tarball | 5.15.211 | No Samsung Project-24 vendor integration by itself | **Not an M14 replacement kernel.** |

The owner's two uploaded Project-24 ZIPs, DTBOs, 300 compiled modules and embedded IKCONFIG are useful *reference artifacts* but do not reconstruct the complete 5.15.211 build source. The existing .ko files embed the original kernel release and cannot be rebranded simply by renaming directories.

## Next legitimate engineering milestone

1. Identify a **full** Project-24 5.15.211 source revision or independently **port and validate** the Samsung M14 vendor/Project-24 modifications from a verified device-specific tree to the intended 5.15.211 Android 13 base. Review the original author's project for published patches and source provenance.
2. Confirm correct Samsung M14 defconfig and DTS, matching firmware/boot layout, Android Clang revision, modules and ABI baseline.
3. Reconcile pinned ReSukiSU and SUSFS/Baseband-guard code **in source**, keeping original copyright and accurate attribution.
4. Compile `Image`, matching `.ko` modules, DTS/DTBO. Run device checks with rollback, *then* build a flashable AnyKernel3 package.

The generic source-gated script `scripts/prepare-kernel.sh` deliberately stops at an incompatible 5.15.153 or 5.15.209 source when set to expected 5.15.211. Never bypass it by simply editing `SUBLEVEL` in a Makefile: that only changes a version number, not the code.

**Status:** Candidate source repos located, no matching final source confirmed, no new compiled or validated JAF Kernel image.
