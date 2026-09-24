# Source audit — corrected using Project-24 Run128 release (22 September 2026)

## 24 September 2026: newer binary reference

The owner uploaded another Project-24 ZIP. [Offline comparison](PROJECT24_2026-09-24_AUDIT.md) shows that **only** its kernel `Image` differs from the prior newer ZIP; it now reports ReSukiSU `v4.2.0-rc3-6803643e` and the same base kernel and configuration. The owner supplied [Run130](https://github.com/MrPankaj24/Project-24/releases/tag/P24-m14x-ReSukiSU-Run130), and GitHub confirms its tag resolves to the **same builder commit as Run128** (`695609d732e99984950b09db5d82901c68f2e514`). The recipe is the same, while moving external dependencies may have changed. The Run128 source/build findings below remain a useful reconstruction starting point, **not proof** that the observed source commit produced the latest image. The new ZIP-to-release asset hash and complete Actions run 130 dependency SHAs/logs remain to be verified. See [Run130 audit](PROJECT24_2026-09-24_AUDIT.md).

## KEY FINDING — original Run128 builder and kernel source located

The owner provided the release [Project-24 Run128](https://github.com/MrPankaj24/Project-24/releases/tag/P24-m14x-ReSukiSU-Run128). The release metadata lists `m14x_defconfig`, `lineage-23.2`, `llvm22-ccache`, root variant `ReSukiSU`, and SUSFS commit `7af04b08f86a5f811cbea28805f96d52368e005f`. Its three release assets have SHA-256 hashes **identical** to the user's newer kernel, DTB and module ZIPs recorded in the inspection reports. Thus this is the published release for the files inspected earlier, not an unrelated build.

The release's tagged [workflow (`.github/workflows/op.yml`)](https://github.com/MrPankaj24/Project-24/blob/P24-m14x-ReSukiSU-Run128/.github/workflows/op.yml) defaults to:

- `KERNEL_SOURCE=https://github.com/devhunter1/android_kernel_samsung_s5e8535.git`
- `KERNEL_BRANCH=lineage-23.2`
- `DEVICE_DEFCONFIG=m14x_defconfig`

**Verified current source snapshot:** [devhunter1/android_kernel_samsung_s5e8535@906601a25962356b037817ed5deaa483b44b9233](https://github.com/devhunter1/android_kernel_samsung_s5e8535/commit/906601a25962356b037817ed5deaa483b44b9233) has `VERSION=5`, `PATCHLEVEL=15`, `SUBLEVEL=211` and `arch/arm64/configs/m14x_defconfig`. This *resolves the earlier source-version mismatch for an experimental source base*. This SHA is the observed source branch HEAD during inspection, **not independently proved to be the exact source commit used by Run128**, since the original workflow clones a moving branch without pinning its commit.

The Project-24 repository holds a complex build workflow, not the whole kernel C source. It imports the devhunter1 tree, then applies upstream and bespoke root/SUSFS, Baseband-guard, Droidspaces, optimization and other patches before building. Do not assume that cloning the raw devhunter1 tree by itself reproduces the binary. The original workflow contains several `patch ... || true` lines and mutable upstream references; a forked/rebuilt version should pin dependencies, review rejected hunks and fail on essential patch failures.

## Historical candidate sources (not Run128's identified primary tree)

| Repository | Inspected branch | Makefile base | Finding |
| --- | --- | --- | --- |
| [MrPankaj24/SM-M146B-Kernel-Source](https://github.com/MrPankaj24/SM-M146B-Kernel-Source) | `main` | 5.15.153 | Older device source; not selected by Run128's workflow. |
| [MrPankaj24/android_kernel_samsung_s5e8535](https://github.com/MrPankaj24/android_kernel_samsung_s5e8535) | `lineage-23.2` | 5.15.209 at inspection | Different fork from Run128's `devhunter1` default; not interchangeable with it. |

## JAF Kernel build path

1. Use the confirmed **devhunter1** source as a pinned starting point, correct `m14x_defconfig`, and the original Run128 tagged workflow as a **recipe to audit**, not blindly copy.
2. Source-apply/reconcile exact ReSukiSU, SUSFS commit, Baseband-guard and other agreed features while keeping true provenance and licenses. Different root hook revisions or patches can conflict.
3. Set `CONFIG_LOCALVERSION="@jaf1887"` in the resolved config, build `Image` and all required *matching* modules/device trees with a controlled Clang version. The original `@MrPankaj24` modules cannot be merely renamed.
4. Review resulting kernel configuration against the uploaded embedded original; verify modem, camera, WLAN and boot/recovery on SM-M146B. Build a model-checked flashable package only after that.

[Our manual experimental workflow](../.github/workflows/build-kernel.yml) now defaults to the identified source repository, pinned **observed** snapshot and `m14x_defconfig`. **It is not a complete port of the original patch/integration workflow** and still fails intentionally if the resolved source lacks requested ReSukiSU/SUSFS/BBG config flags. No completed JAF kernel or tested ZIP exists.
