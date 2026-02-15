#!/bin/bash
# (c) 2026, Roberto A. Foglietta <roberto.foglietta@gmail.com>, MIT license

append_for_kernel_debug="earlyprintk=serial nokaslr -pidfile vm.pid -panic=1"

kimg="${2:-bzImage}"
qemubin="qemu-system-x86_64"
rfsimg="${1:-initramfs.cpio}"; test -r ${rfsimg}.gz && rfsimg="${rfsimg}.gz"  
cmd="$qemubin -kernel ${kimg} -initrd ${rfsimg} -nographic -no-reboot\
    -enable-kvm -cpu host -machine accel=kvm -boot order=dc -name tinylnx $QARGS\
    -append 'HOST=x86_64 root=/dev/ram0 rdinit=/init console=ttyS0 net.ifnames=0'"\

sh -c "$cmd $@"; stty sane; printf '\e[?7h'

# Under development, updating the image before start it
rfsdir=${rfsimg/.cpio.gz/}; rfsdir=${rfsdir/.cpio/}
if [ -d update/$rfsdir/ ]; then
  printf "Checking is ramfs update "
  if ! md5sum -c update/initramfs.md5 2>/dev/null; then
    sh cpio.sh -e $rfsimg tmp1 2>&1 | grep -E "cpio: | blocks"
    cp -arf update/$rfsdir/* tmp1 2>&1
    sh cpio.sh -c $rfsimg tmp1 2>&1
  fi
fi
