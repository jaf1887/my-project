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

## Consequences for JAF Kernel

- This ZIP is now the **latest owner-provided compiled reference image** and reports ReSukiSU `v4.2.0-rc3-6803643e`.
- It still contains **no complete source tree**, no `@jaf1887` binary and no JAF modules.
- For actual JAF source work, see [source audit](SOURCE_AUDIT.md): the earlier original Run128 workflow identified the devhunter1 5.15.211 M14 tree and build recipe. **This latest ZIP has not been matched to a specific upstream Project-24 release/workflow/source SHA.**
- Do not present this binary comparison as a validation of flashing, actual running features or module compatibility.
