# `jaf1887` kernel identity — source-level change only

The requested **future build label** is `5.15.211-android13-8@jaf1887`, keeping the exact kernel version/Android suffix only if it remains accurate for the rebuilt source. This is a label for a derivative build, **not** a claim that the original Project-24 source or kernel was authored by `jaf1887`.

The user-uploaded *newer* Project-24 AnyKernel3 ZIP still contains six literal instances of `MrPankaj24` in its compiled ARM64 `Image`, two in `anykernel.sh`, and one in `banner`. One instance of the localversion also occurs in its *gzip-compressed* embedded IKCONFIG, which is not visible to a naive binary string replacement. References include `uname -r`, kernel version diagnostics, module metadata and firmware lookup paths. Editing these strings directly in the executable can break the boot process, module loading, embedded config consistency, or binary integrity. **Do not binary-patch and repackage the original ZIP as if it were rebuilt.**

The new build configuration template should use:

```text
CONFIG_LOCALVERSION="@jaf1887"
# CONFIG_LOCALVERSION_AUTO is not set
```

A copy of the uploaded Image's embedded `.config` with only `CONFIG_LOCALVERSION` changed is available as a separate conversation download, not as a new kernel. For a matching **complete** source tree and configured build output, run:

```bash
bash scripts/set-kernel-localversion.sh work/out/.config
bash scripts/build-image.sh
```

First verify that the 5.15.211 Project-24 source, vendor patches, device-specific defconfig, pinned ReSukiSU and correct SUSFS integration are all present. `build-image.sh` now requires `CONFIG_LOCALVERSION="@jaf1887"` and the root/SUSFS config flags, but a successful build still does not produce a ready-to-flash ZIP.

Keep licences, copyright notices and accurate credit to the original kernel developer, ReSukiSU, SUSFS and AnyKernel3 in any eventual derivative release. An installer can display `Custom build by jaf1887; based on Project-24 by MrPankaj24` once a **genuine** rebuild has occurred. Do not replace the original author's credit with a false authorship claim.

Changing the release string can also change kernel module and firmware search paths. Build and validate matching vendor modules, DTB/DTBO and boot image layout; arrange a recovery/rollback path before flashing.
