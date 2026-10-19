# Run130 feature review — 19 October 2026

The boot-tested JAF build 4 config already enables SUSFS path, mount, kstat,
map hiding and Baseband Guard, matching the previously inspected Project-24
Run130 feature selections. Runtime policy still needs checking on the phone;
enabled Kconfig flags alone do not establish effective hiding.

The pinned workflow now explicitly enables these SUSFS selections and checks
that Exynos support, module versions and Baseband Guard LSM registration survive
olddefconfig. Boot/recovery partition blocking stays disabled to preserve the
existing recovery route. This does not disable protection of other partitions.

## Optimization review

Upstream candidate repository: WildKernels/kernel_patches at
`3ade2ad1514e25a3f68314169f257eeb2b7f6063`.

The clear_page alignment patch applies cleanly to the exact Samsung source
`906601a25962356b037817ed5deaa483b44b9233` after normalizing local line endings.
It is offered as an opt-in workflow input, disabled by default. This is a patch
application check, not a measured performance improvement or boot test.

The Exynos memcmp candidate fails a hunk at line 108 even after adapting the
5.15 symbol names. It is excluded until manually ported and functionally tested.
The older workflow's practice of tolerating rejects and deleting evidence must
not be copied.

## Play Integrity

Play Integrity is a Google Play services/API verdict, not a kernel Kconfig
feature. No passing verdict is asserted by these changes. Previous device tests
reported failures and KeyMint CANNOT_ATTEST_IDS errors; those September results
need a fresh test before drawing conclusions about the current phone.

Record current BASIC/DEVICE/STRONG results, actual firmware/model and narrow
KeyMint errors locally. Do not publish device identifiers or private keyboxes.
Diagnose model/firmware consistency before adding more spoofing layers.

Reference: https://developer.android.com/google/play/integrity/setup

## Remaining validation

Compile the baseline configuration and the optional alignment configuration
separately in Linux CI. Check patch logs, resolved config, Image, matching
modules and device trees. Only package a new candidate after successful build
checks; it needs its own device boot and runtime tests. The existing boot-tested
release is not replaced by this source change.
