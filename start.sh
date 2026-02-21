#!/bin/bash
# (c) 2026, Roberto A. Foglietta <roberto.foglietta@gmail.com>, MIT license

qemubin="qemu-system-x86_64"
append_for_kernel_debug="earlyprintk=serial nokaslr -pidfile vm.pid -panic=1"

update=0
tstimg=0
if [ "x${1:-}" = "x-t" ]; then
  tstimg=1
  shift;
elif [ "x${1:-}" = "x-u" ]; then
  update=1
  tstimg=1
  shift;
fi

if [ "x${1:-}" = "x-r" ]; then
  rfsimg="initrobfs.cpio"
  shift; set -- "$rfsimg" "$@"
else
  rfsimg="${1:-initramfs.cpio}"
fi
test -r ${rfsimg}.gz && rfsimg="${rfsimg}.gz"
kimg="${2:-bzImage}"
tmpdir=${3:-cpio.tmp}

# Updating the image before start it

rfsdir=$(echo "$rfsimg" | sed 's/\.cpio\.gz//;s/\.cpio//')
chkmd5() { echo | md5sum -c update/$rfsdir.md5 2>/dev/null; }

if [ -d update/$rfsdir/ ]; then
  printf "Checking is ramfs update "
  if ! chkmd5; then
    sh cpio.sh -e $rfsimg $tmpdir 2>&1 | grep -E "cpio: | blocks"
    cp -arf -pd update/common/* update/$rfsdir/* $tmpdir/ 2>&1
    sh cpio.sh -c $rfsimg $tmpdir 2>&1
    if ! chkmd5; then
      echo "ERROR: ramfs updated doesn't match md5 checksum"
      echo "       press ENTER to start the QEMU VM anyway."
      read x
    fi
    rm -rf $tmpdir
  fi
fi

if [ $update -ne 0 ]; then
  md5sum $rfsimg > update/$rfsdir.md5
fi
test $tstimg -eq 0 || exit

# Starting the QEMU virtual machine

cmd="$qemubin -m 32 -kernel ${kimg} -initrd ${rfsimg} -nographic -no-reboot \
-enable-kvm -cpu host -machine accel=kvm -boot order=dc -name tinylnx $QARGS \
-append 'HOST=x86_64 root=/dev/ram0 init=/init console=ttyS0 net.ifnames=0'"

sh -c "$cmd"; stty sane; printf '\e[?7h'

