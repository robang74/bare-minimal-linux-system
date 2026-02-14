#!/bin/sh
# (c) 2026, Roberto A. Foglietta <roberto.foglietta@gmail.com>, MIT license

append_for_kernel_debug="earlyprintk=serial nokaslr -pidfile vm.pid -panic=1"

kimg="${2:-bzImage}"
rfsimg="${1:-initramfs.cpio}"; test -r ${rfsimg}.gz && rfsimg="${rfsimg}.gz"  
cmd="qemu-system-x86_64 -kernel ${kimg} -initrd ${rfsimg} -nographic -no-reboot\
    -enable-kvm -cpu host -machine accel=kvm -boot order=dc -name tinylnx $QARGS\
    -append 'HOST=x86_64 root=/dev/ram0 rdinit=/init console=ttyS0 net.ifnames=0'"\

sh -c "$cmd $@"; stty sane; printf '\e[?7h'
