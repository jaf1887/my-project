# Samsung Galaxy M14 5G — Resuki SU kernel

Kernel development workspace for the Samsung Galaxy M14 5G with Resuki SU integration.

> **Status: planning / source verification.** This repository does **not** contain a built kernel, a flashable image, or verified Resuki SU integration yet. Do not flash anything from this repository until the exact device, firmware, source tree, build procedure and recovery method have been verified.

## Project goals

- Identify the exact Galaxy M14 5G model, region, firmware build, Android version and existing kernel revision.
- Locate the corresponding Samsung kernel source and preserve its notices and licence terms.
- Identify the correct Resuki SU upstream, revision and integration procedure.
- Create a reproducible build process and record toolchain versions.
- Test boot, root access and core hardware functionality on the matching device before publishing any release.

## Development status

| Step | Status |
| --- | --- |
| Confirm exact device and firmware | Not yet verified |
| Import matching kernel source | Not started |
| Integrate Resuki SU | Not started |
| Reproducible build | Not started |
| Device testing | Not started |
| Release | Not available |

## Before building

See [docs/BUILD_PLAN.md](docs/BUILD_PLAN.md) for the inputs and acceptance checks. Keep firmware images, backups, credentials and personally identifying device dumps out of this public repository.

## Safety

The Galaxy M14 5G must not be treated as interchangeable with other Galaxy M14 variants. Do not flash a boot image built for a different model or firmware. Preserve a tested recovery path and a complete backup before any on-device testing.

## Licence

No third-party kernel source or Resuki SU code has been imported. When source is added, retain its upstream copyright and licence information; document separate component licences as required.
