# Full original JAF Kernel configuration

The owner extracted `Project24-m14x-jaf1887.config` from the original compiled Project-24 kernel's embedded IKCONFIG and changed only `CONFIG_LOCALVERSION` to `"@jaf1887"`. The file is ~232 KiB.

**It is NOT yet committed to this GitHub folder.** Download the file from the earlier chat attachment and use GitHub's **Add file → Upload files** to add it as:

`configs/Project24-m14x-jaf1887.config`

Do not upload a renamed `.ko`, the old Project-24 binary `Image`, IMEI data, private boot backups or unrelated firmware to this public repository.

When uploaded, the [CI](../.github/workflows/kernel-ci.yml) workflow will run `scripts/kernel-preflight.sh` on it. A successful preflight proves configuration flags are present, **not** matching 5.15.211 source, module ABI, compatibility or bootability.

The manually triggered experimental [Image builder](../.github/workflows/build-kernel.yml) requires this file and a verified full M14 source commit whose kernel base is `5.15.211`. It does **not** automatically use the `5.15.153` or `5.15.209` source candidates. An image built with different source configuration or a different Clang than the original `Ubuntu clang 22.1.8` must be considered **unvalidated** until the differences are reviewed and the actual device and modules have been tested.
