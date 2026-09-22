# SUSFS update target for Project-24 SM-M146B

**Status: target researched, kernel NOT rebuilt or flashed.**

The owner-uploaded Project24 m14x ReSukiSU ZIP was previously inspected and reported embedded `SUSFS v2.3.0`, `CONFIG_KSU_SUSFS=y`, and Linux `5.15.211-android13-8@MrPankaj24`. The ZIP is an AnyKernel3 compiled `Image`, not editable kernel source. See [PROJECT24_ZIP_INSPECTION.md](PROJECT24_ZIP_INSPECTION.md) and [DEVICE.md](DEVICE.md).

## Which SUSFS update?

On 22 Sep 2026, the official SUSFS project branch for this GKI family is:

- Source: <https://gitlab.com/simonpunk/susfs4ksu/-/tree/gki-android13-5.15>
- The branch shows **SUSFS 2.3.0**. Thus the inspected image already reports this numeric version.
- The branch's newer HEAD shown during research is abbreviated `415e4143` (a kernel/KernelSU su-session ordering fix). This is a **patch-level source update within v2.3.0**, not verified to be a new numbered SUSFS version or compatible with Project-24's ReSukiSU fork.

**Do not install a userspace SUSFS module and claim that it has updated the compiled kernel code.** Also do not swap a GKI boot image or kernel patch from a different Android/kernel branch onto SM-M146B.

## Implementation gates

1. Obtain the matching **full 5.15.211 Project-24 SM-M146B source tree**, its exact original SUSFS patch baseline, vendor commits, and boot/repack procedure. The inspected public `MrPankaj24/SM-M146B-Kernel-Source` tree was based on 5.15.153, so cannot be assumed a drop-in match.
2. Fetch the official `gki-android13-5.15` SUSFS source, record a **full immutable commit SHA**, inspect diff against the original SUSFS patch baseline, and audit licensing.
3. Rebase/port the kernel-side SUSFS and its KernelSU/ReSukiSU hook changes against the **pinned** ReSukiSU revision in the main README. Official SUSFS documentation warns that patches can differ even within the same kernel release and may conflict with custom hook patches. Do not blindly apply both sets of overlapping hook patches.
4. Preserve the supplied embedded defconfig, especially `CONFIG_KSU=y` and `CONFIG_KSU_SUSFS=y`; resolve Kconfig/ABI/module issues, then compile with the exact Samsung source toolchain.
5. Before publishing a flashable package, verify boot image/DTB/DTBO/modules, complete recovery backup, boot and root access on **this exact phone**, and runtime SUSFS reports/logs. A passing patch command or successful `Image` compilation does not validate a flashable release.

**Nothing in this repository currently contains a rebuilt or validated SUSFS kernel image.**
