# Baseband-guard in the existing Project-24 M14 5G kernel

Source supplied by owner: <https://github.com/vc-teahouse/Baseband-guard>. Its documentation describes an Android Linux Security Module (LSM) designed to block unauthorized writes to protected partitions/device nodes; the upstream project describes itself as work in progress. It is **not** the cellular baseband/modem firmware and does not supply a device kernel source tree.

## Verified from uploaded Project-24 kernel

Inspection of the owner-provided newer `Project24-Kernel-m14x-ReSukiSU.zip` ARM64 `Image` showed compiled-in `baseband_guard` log messages and the original upstream repository URL. The extracted embedded IKCONFIG and the modified `Project24-m14x-jaf1887.config` both contain:

```text
CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,bpf,baseband_guard"
CONFIG_BBG=y
# CONFIG_BBG_BLOCK_BOOT is not set
# CONFIG_BBG_BLOCK_RECOVERY is not set
```

Thus Baseband-guard is **already compiled in**, enabled and listed in the kernel LSM configuration. Its optional boot and recovery partition blocking are disabled in this build. No extra action is needed to put this option into the proposed modified `.config`.

## Integration in an independent source build

Once the *matching complete* Project-24 5.15.211 kernel/vendor source becomes available, preserve Baseband-guard alongside ReSukiSU and SUSFS. For a genuinely new source tree, inspect the project's `setup.sh`, `Kconfig`, `Makefile`, security hooks and partition protection rules, pin the upstream revision, and merge with already present LSM integrations; avoid duplicating it if Project-24 source includes it already.

Upstream: <https://github.com/vc-teahouse/Baseband-guard/blob/main/docs/README-en.md>, <https://github.com/vc-teahouse/Baseband-guard/blob/main/Kconfig>. Its `Kconfig` warns that turning on `CONFIG_BBG_BLOCK_BOOT` may interfere with flashing kernels from within Android. Do not enable this or recovery blocking without validating a tested recovery path.

**Finding the project used does not provide the complete missing kernel source, change ELF module vermagic, update SUSFS, or make a new `@jaf1887` kernel flashable.** No such new kernel was built or flashed.
