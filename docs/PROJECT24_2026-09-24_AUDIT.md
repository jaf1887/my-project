# Project-24 24 September 2026 user-uploaded ZIP audit

Owner uploaded `Project24-Kernel-m14x-ReSukiSU (8).zip`. Inspection was **offline and read-only**; no installation scripts were run, nothing was flashed.

## Compare to earlier Project-24 ZIP

| Property | Earlier newer ZIP (`Project24-Kernel-m14x-ReSukiSU.zip`) | 24 Sep ZIP (`... (8).zip`) |
| --- | --- | --- |
| ZIP SHA-256 | `2e624126bb5213d32eec428f2b8aa4c173928dbffc353305adfb4afd9c9721e9` | `d9bcbc654da850a4d2e31846860fc4c4ca7403228558f00fd07d2f13da4bf067` |
| Embedded `Image` SHA-256 | `95d6356883947ba438d2efbbfac3a5edb5de915fd64835aac8ba02b62d4617f9` | `19f535084dd8a6e954920d04f6536c9b33116ae927dd47717a59fc7010b44c1d` |
| `Image` size | 50,633,216 bytes | 50,633,216 bytes |
| Embedded Linux release | `5.15.211-android13-8@MrPankaj24` | Same |
| ReSukiSU identifier | `v4.2.0-rc2-9be0f347@ReSukiSU` | **`v4.2.0-rc3-6803643e@ReSukiSU`** |
| SUSFS version string | `v2.3.0` | `v2.3.0` |
| Embedded IKCONFIG SHA-256 | `af842de9f958d7e95b0ae7d40af47e6bac0bd2d0f517e6edbe7909a54a178942` | Same |
| Baseband-guard | `CONFIG_BBG=y`; named in `CONFIG_LSM` | Same |
| Package membership | 19 entries | 19 entries; **only `Image` bytes differ** |
| ZIP integrity test | Passed in earlier audit | Passed |

ReSukiSU short SHA in the binary resolves to [upstream full commit `6803643e19e2e6e8287f96461aabb93bdd6c47fa`](https://github.com/ReSukiSU/ReSukiSU/commit/6803643e19e2e6e8287f96461aabb93bdd6c47fa). Its identifier is a *binary-reported revision*, not independently proven source-level reproduction.

The embedded config retains `CONFIG_LOCALVERSION="@MrPankaj24"`, `CONFIG_KSU=y`, `CONFIG_KSU_SUSFS=y`, `CONFIG_BBG=y`; `CONFIG_CGROUP_PIDS`, `CONFIG_CGROUP_DEVICE`, `CONFIG_BRIDGE_NETFILTER` and `CONFIG_NF_TABLES` remain disabled. **No Droidspaces config gap has been closed in this image.**

## Installer and modules

The AnyKernel3 installer is byte-identical to the previous ZIP. It specifies `block=boot`, `do.devicecheck=0`, `do.modules=0`. It does not ship new modules or device trees. Owner's *separate older* 300-module archive still embeds `5.15.211-android13-8@MrPankaj24`; identical vermagic naming is not proof that module ABI is unchanged. Rebuild and test appropriate modules for `@jaf1887`; never rename existing `.ko` metadata to suggest compatibility.

## Run130 release tag traced (owner-supplied URL)

The owner supplied [Project-24 Run130](https://github.com/MrPankaj24/Project-24/releases/tag/P24-m14x-ReSukiSU-Run130). GitHub's commit resolution and compare show that **Run128 and Run130 release tags point to exactly the same build-repository commit** [`695609d732e99984950b09db5d82901c68f2e514`](https://github.com/MrPankaj24/Project-24/commit/695609d732e99984950b09db5d82901c68f2e514); comparison is identical, zero commits ahead/behind. The repository recipe is therefore unchanged between the tags; the separate GitHub Actions runs could still have pulled different **moving upstream kernel/ReSukiSU branch heads**, yielding different compiled `Image` files.

Verified [Run130-tagged `.github/workflows/op.yml`](https://github.com/MrPankaj24/Project-24/blob/P24-m14x-ReSukiSU-Run130/.github/workflows/op.yml) declares these **default inputs**, not independently verified actual run overrides:

- `KERNEL_SOURCE=https://github.com/devhunter1/android_kernel_samsung_s5e8535.git`, `KERNEL_BRANCH=lineage-23.2`, `DEVICE_DEFCONFIG=m14x_defconfig`.
- `toolchain_mode=llvm22-ccache`, `KSU_VARIANT=ReSukiSU`, `MANAGER_BRANCH=main`.
- `ENABLE_SUSFS=true`, `SUSFS_SHA=7af04b08f86a5f811cbea28805f96d52368e005f`.
- `ENABLE_DROIDSPACE=true`; pulls `MrPankaj24/kernel_patch/main/Droidspace/droidspace_for_1330.patch`.
- Baseband-guard setup and `CONFIG_BBG=y` are always invoked in the workflow; `CONFIG_LOCALVERSION="@MrPankaj24"` is set in the generated root config.

**Build reproducibility caution:** The workflow shallow-clones the *moving* `lineage-23.2` branch, clones ReSukiSU `main`, fetches some `main` patches, and permits `patch ... || true` failures. Its release-body descriptions are assertions, not verification of every runtime feature; in particular the inspected `Image` still reports disabled Droidspaces-related cgroup/network configs. A pinned tag in the **builder repo** does not pin its external source dependencies. To reproduce Run130 exactly, capture GitHub Actions run 130 logs/provenance, source HEAD, ReSukiSU SHA, toolchain digest and patch results; then compare the published release asset's SHA-256 against the uploaded ZIP SHA-256 above. The release metadata/asset hash could not be fetched automatically through the available release API here, so the user's identification of the ZIP as Run130 is not yet independently hash-verified.

## Consequences for JAF Kernel

- This ZIP is now the **latest owner-provided compiled reference image** and reports ReSukiSU `v4.2.0-rc3-6803643e`.
- It still contains **no complete source tree**, no `@jaf1887` binary and no JAF modules.
- For actual JAF source work, see [source audit](SOURCE_AUDIT.md): the earlier original Run128 workflow identified the devhunter1 5.15.211 M14 tree and build recipe. **The user identifies it as Run130, and that tag's builder workflow has been inspected; **release asset hash and exact external source SHA are not yet independently verified**.**
- Do not present this binary comparison as a validation of flashing, actual running features or module compatibility.
