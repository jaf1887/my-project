# Build #1 failure: SUSFS 50 patch rejects

The owner's 24 September screenshot of the GitHub Actions job `JAF Run130 Pinned Experimental Build #1` shows:

- Samsung source checkout succeeded.
- `Integrate pinned Run130 root, SUSFS, BBG and Droidspaces sources` exited code **3**.
- During the pinned upstream SUSFS `50_add_susfs_in_gki-android13-5.15.patch` application, the log reported **8 failed hunks** in the `fs/namespace.c` section (cropped to `… of 8 hunks FAILED`). Other files/hunks applied, some with offsets.
- Our script stopped at `SUSFS 50 patch conflict: source needs manual review`, **before** the Project-24 `51_susfs_fix.patch`, Baseband-guard, Droidspaces and compilation stages.

**Diagnosis:** This pinned upstream SUSFS 50 patch is not directly applicable to every part of the selected Samsung/devhunter1 5.15.211 source tree. A failure with other hunks applying is a *partially modified tree*; deleting `.rej`, ignoring `patch` exit code or enabling SUSFS in `.config` does **not** implement the missing hooks.

**Change made:** [`scripts/integrate-run130.sh`](../scripts/integrate-run130.sh) now preserves `susfs-50-patch.log`, an archive `rejected-hunks.tar.gz`, the original `fs/namespace.c.rej` when present and rejects list under `work/reports/` prior to fail-closed exit. The existing [workflow](../.github/workflows/jaf-run130-pinned.yml) uploads those reports as an artifact even on failure.

**Required engineering work:** inspect the actual rejected hunks and relevant source sections, port missing SUSFS mount hooks to the source in a reviewed device-specific patch, confirm all hunks and config symbols, then retry an Image/modules/dtb build. Do not claim Run130 source-level equivalence or a bootable artifact from the screenshot alone.

Upstream SUSFS documentation itself warns that kernel patches may need manual adjustments even across the same kernel version: https://gitlab.com/simonpunk/susfs4ksu
