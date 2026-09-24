# GitHub Actions setup — JAF Kernel

Three workflows are committed to `main`. The cloud runner is Ubuntu 24.04. **Neither workflow flashes the phone or publishes a release.**

## A. Automatic validation

[Kernel CI](../.github/workflows/kernel-ci.yml) runs on relevant pushes and pull requests and can also be started manually using **Actions → JAF Kernel CI → Run workflow**. It checks shell syntax, tests that the old 5.15.153 source is rejected when 5.15.211 is expected, and checks the full reference config **if present**.

This CI does **not** compile Linux or prove that a kernel is bootable.

## B. Manual experimental compilation

[Experimental Image Build](../.github/workflows/build-kernel.yml) uses **Actions → JAF Kernel Experimental Image Build → Run workflow**. Required inputs:

- `source_repo`: a **verified full source repository** in `OWNER/REPO` form, with SM-M146B drivers, M14 defconfig, ReSukiSU, SUSFS and Baseband-guard actually integrated.
- `source_commit`: reviewed, exact 40-character source commit SHA. The source must genuinely contain the correct 5.15.211 code. Merely editing `SUBLEVEL` will not make a mismatched kernel compatible.
- `defconfig`: name of the M14 defconfig target that exists in that exact source, e.g. `s5e8535-m14xnsxx_defconfig` **if verified**.

Before running it, upload the provided earlier extracted file to `configs/Project24-m14x-jaf1887.config` (see [configs/README.md](../configs/README.md)). **This file is not yet in GitHub.**

Build steps: validate inputs/config → install compilation packages → clone exact SHA → refuse mismatched kernel base → configure source and apply `@jaf1887` suffix → refuse missing ReSukiSU/SUSFS/Baseband guard flags → attempt `Image modules dtbs` build → store **unvalidated raw artifacts**, module archive, device trees, configuration and SHA-256 hashes for 7 days.

The hosted runner's available Clang may not match the original `Ubuntu clang 22.1.8`. This is an experimental scaffold, **not a reproducible Project-24 toolchain**. The exact source's build script, Clang/prebuilts and vendor toolchain must be matched before expecting compilation or device compatibility. A build that exits with success still needs KMI/CRC, module, firmware, device-tree, boot-format and on-device testing. The artifact is intentionally not called a flashable ZIP.

**Source-discovery update:** the original Run130 workflow identifies the devhunter1 Samsung 5.15.211 source and `m14x_defconfig`; see [SOURCE_AUDIT.md](SOURCE_AUDIT.md). This existing experimental workflow is intentionally an earlier scaffold and is not the new pinned Run130 integration workflow below.

## C. NEW: Run130-pinned experimental source integration and compilation

[Run130 pinned build](../.github/workflows/jaf-run130-pinned.yml) can be selected at **Actions → JAF Run130 Pinned Experimental Build → Run workflow**. It does **not** need the owner's original extracted full config uploaded: it generates a fresh config from the pinned source `m14x_defconfig`, enables selected agreed settings and uploads its **actual resolved configuration** for review.

The workflow pins the *observed* devhunter1 source commit `906601a25962356b037817ed5deaa483b44b9233`, ReSukiSU `6803643e19e2e6e8287f96461aabb93bdd6c47fa`, SUSFS `7af04b08f86a5f811cbea28805f96d52368e005f`, Baseband-guard `a54e0dc6cf0aff4dd87fec49644a02d2eb612905` and Project-24 auxiliary patch repo `82c26549197e0288167514c4054e503049bc1051`. Only the source repo and upstream ReSukiSU SHA have been tied to prior inspection and the new Image identifier respectively; these are **not proven to be all the exact Run130 dependencies**.

[Integration script](../scripts/integrate-run130.sh) clones each source at its pinned commit, sets up ReSukiSU, applies Run130 SUSFS core plus Project-24-specific fix, wires Baseband-guard and applies the Exynos 1330 Droidspaces ABI padding patch. Required patch failures **stop the job** instead of being hidden by `|| true`. It then attempts to configure and compile a raw `Image`, fresh matching `.ko` modules and DTB/DTBO files. Uploads logs, hashes, configs and any build outputs as `jaf-run130-experimental-<run number>` for diagnosis, even on build failure.

**Caveats:** This is a deliberately limited, source-level **engineering attempt**, not a reproduction of every Run130 optimization or its NoMount/Re:Kernel/BBRv3/other patches. It uses the runner's distro Clang rather than the specific original LLVM 22/ccache toolchain. It does not establish module ABI or on-device compatibility. The Droidspaces patch supplies SYSVIPC kABI padding but **does not itself enable all absent Droidspaces configs**. **No resulting artifact is a flashable ZIP.**

If integration stops, open the failed Actions run and share the **first failed patch or compiler error**, not just the final failure banner. This is useful information to fix the source port properly.

### If Actions is not visible

Enable Actions for the repository under its GitHub Settings → Actions permissions. See the GitHub Actions page for the repository. No external token, secret, device connection or local PC is required for *CI validation*.
