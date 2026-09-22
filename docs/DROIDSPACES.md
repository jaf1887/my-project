# Droidspaces support audit — Project-24 SM-M146B

Requested project: https://github.com/ravindu644/Droidspaces-OSS

Droidspaces is primarily an Android/Linux **userspace container runtime** and Android application. It is **not** another replacement M14 kernel or the missing Project-24 source. Official kernel guidance: https://github.com/ravindu644/Droidspaces-OSS/blob/main/Documentation/Kernel-Configuration.md

## Evidence from owner's original Project-24 extracted IKCONFIG

Already enabled (`=y`): `CONFIG_SYSVIPC`, `CONFIG_POSIX_MQUEUE`, `CONFIG_NAMESPACES`, `CONFIG_PID_NS`, `CONFIG_UTS_NS`, `CONFIG_IPC_NS`, `CONFIG_NET_NS`, `CONFIG_USER_NS`, `CONFIG_CGROUPS`, `CONFIG_MEMCG`, `CONFIG_CGROUP_FREEZER`, `CONFIG_DEVTMPFS`, `CONFIG_OVERLAY_FS`, `CONFIG_VETH`, `CONFIG_BRIDGE`, `CONFIG_NETFILTER`, `CONFIG_NF_CONNTRACK`, `CONFIG_NF_NAT`, `CONFIG_IP_NF_IPTABLES`, `CONFIG_IP_NF_FILTER`, `CONFIG_NETFILTER_XT_MATCH_ADDRTYPE`, `CONFIG_SECCOMP`, `CONFIG_SECCOMP_FILTER`, `CONFIG_TMPFS_POSIX_ACL`, `CONFIG_TMPFS_XATTR`.

Absent/disabled in extracted config:

```text
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_BRIDGE_NETFILTER is not set
# CONFIG_NF_TABLES is not set
```

The Droidspaces kernel-configuration documentation lists `CONFIG_CGROUP_DEVICE=y`, `CONFIG_CGROUP_PIDS=y`, and `CONFIG_DEVTMPFS=y` as required/fatal if absent for its full container workflow, though actual runtime results depend on kernel behaviour and userspace environment. Thus do **not** claim the present Project-24 image is fully Droidspaces-compatible just because namespace support is present. Networking/firewall support may be restricted when bridge netfilter or nftables is disabled.

**GKI 5.15 warning:** the upstream guide states that some config changes require matching kABI-compatible patches and may break prebuilt vendor module compatibility/boot if enabled blindly. This project has a separate Project-24 module archive whose module ABI/release must be preserved. Do not switch missing flags to `y` in the standalone `.config` and pretend the binary kernel has changed or the resulting build is safe. Identify matching kernel source and patch baseline, then integrate/test as one coordinated source + modules build.

## Safer immediate check on the rooted phone

Install Droidspaces according to its own Android installation documentation. In its Android app use **Settings → Requirements → Check Requirements**, or if its CLI is installed, run `su -c droidspaces check`. This is a feature probe, not a kernel flash. Root access and SELinux/device policy may also affect behaviour independently of compile-time options. Avoid permissive SELinux or privileged container settings unless necessary and understood.

**Project status:** documented requirements and gaps; no independent `@jaf1887` kernel compiled, no claim Droidspaces runs successfully on SM-M146B, and nothing flashed.
