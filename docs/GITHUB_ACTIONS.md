# GitHub Actions setup — JAF Kernel

Two workflows are committed to `main`. The cloud runner is Ubuntu 24.04. **Neither workflow flashes the phone or publishes a release.**

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

**At present, neither of the two located public source candidates (`5.15.153` and `5.15.209`) passes the required `5.15.211` source gate. Do not enter either into the build workflow expecting a usable kernel.** Resolve the source and exact defconfig first, or independently port/validate the source and matching modules.

### If Actions is not visible

Enable Actions for the repository under its GitHub Settings → Actions permissions. See the GitHub Actions page for the repository. No external token, secret, device connection or local PC is required for *CI validation*.
