#!/system/bin/sh
# Run in Termux or adb shell on the Galaxy M14 5G. Read-only; does not change the phone.
printf 'Hardware model: '; getprop ro.boot.em.model
printf 'System model (may be spoofed): '; getprop ro.product.model
printf 'Firmware build: '; getprop ro.build.display.id
printf 'Build fingerprint: '; getprop ro.build.fingerprint
printf 'Android release: '; getprop ro.build.version.release
printf 'Kernel release: '; uname -r
printf 'Kernel version: '; uname -v
