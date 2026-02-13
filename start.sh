#!/bin/sh
# (c) 2026, Roberto A. Foglietta <roberto.foglietta@gmail.com>, MIT license

cmd="qemu-system-x86_64 -kernel bzImage -initrd initramfs.cpio -nographic \
    -no-reboot -append 'root=/dev/ram0 rdinit=/init console=ttyS0 net.ifnames=0'\
    -enable-kvm -cpu host -machine accel=kvm -boot order=dc -name tinylnx"
append_for_kernel_debug="earlyprintk=serial nokaslr -pidfile vm.pid -panic=1"
sh -c "$cmd $@"
stty sane
