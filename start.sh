#!/bin/bash
# (c) 2026, Roberto A. Foglietta <roberto.foglietta@gmail.com>, MIT license

qemubin="qemu-system-x86_64"
append_for_kernel_debug="earlyprintk=serial nokaslr -pidfile vm.pid -panic=1"

# Cope with the user's parametric input

test -r bzImage || ln -sf bzImage.orig bzImage

docpio=1
update=0
tstimg=0

if [ "x${1:-}" = "x-z" ]; then
  export QZERO=1
  shift
fi

if [ "x${1:-}" = "x-t" ]; then
  tstimg=1
  shift;
elif [ "x${1:-}" = "x-u" ]; then
  update=1
  tstimg=1
  shift;
fi

if [ "x${1:-}" = "x-T" ]; then
  docpio=0
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
tmpdir=${3:-}

if [ ! -n "$tmpdir" ]; then
  tmpdir="cpio.tmp/"
  trap "rm -rf $tmpdir; return 1" EXIT INT TERM
  rm -rf $tmpdir
fi

# Updating the image before start it

rfsdir=$(echo "$rfsimg" | sed 's/\.cpio\.gz//;s/\.cpio//')
chkmd5() { md5sum -c update/$rfsdir.md5 2>/dev/null; }

if [ $docpio -ne 0 -a -d update/$rfsdir/ ]; then
  printf "Checking is ramfs update "
  if ! chkmd5; then
    sh cpio.sh -e $rfsimg $tmpdir 2>&1 | grep -E "cpio: | blocks"
    cp -arf -pd update/common/* update/$rfsdir/* $tmpdir/ 2>&1
    sh cpio.sh -c $rfsimg.new $tmpdir 2>&1
    rfsimg="$rfsimg.new"
    if ! chkmd5; then
      echo "ERROR: ramfs updated doesn't match md5 checksum"
      echo "       press ENTER to start the QEMU VM anyway."
      test $update -eq 0 && read x
    fi
    rm -rf $tmpdir
  fi
fi

test -r $rfsimg.new && rfsimg="$rfsimg.new"

if [ $update -ne 0 ]; then
  md5sum $(find $rfsimg update/common/ update/$rfsdir/ ! -type d) > update/$rfsdir.md5
fi

test $tstimg -eq 0 || exit

# Starting the QEMU virtual machine

# spxdup="memtest=0 deferred_probe_timeout=0 quiet loglevel=3 page_alloc.shuffle=0"
# export QTTYC=${QTTYC:-8250.nr_uarts=1 console=ttyS0,115200n8}
# cmdlnx+=" lpj=1234567"

if [ "${QZERO:-0}" != "0" ]; then
  boxnme="-name tinylnx"
  qaccel="-enable-kvm -cpu host -machine accel=kvm"
  netisl="-netdev user,id=net0,restrict=yes -device virtio-net-pci,netdev=net0"
  cmdlnx="HOST=x86_64 root=/dev/ram0 init=/init console=ttyS0 net.ifnames=0 nokaslr"
  cmdlnx="-append '$cmdlnx'"
else
  echo
  echo "Zero Kelvin Linux mode"
  echo
  boxnme="-name zroklnx"
  qaccel="-accel tcg"
  qaccel+=" -M microvm,x-option-roms=off,pit=off,pic=off,rtc=off,acpi=off"
  qaccel+=" -icount shift=0,sleep=off,align=off -nodefaults -serial mon:stdio"
fi

cmd="$qemubin -m ${QMSZE:-128M} -kernel ${kimg} -initrd ${rfsimg} -nographic -no-reboot \
    -boot order=dc ${boxnme:-} ${qaccel:-} ${netisl:-} ${cmdlnx:-} ${QARGS:-}"

sh -xc "$cmd"; stty sane; printf '\e[?7h'

# dmesg | uchaos -i 16 -d 3 -qT 4 -r 31 -k /dev/random >/dev/null

# for i in $(seq 1 $((32*8))); do dmesg | uchaos -i 16 -d 3 -r 31 -qM 128;
#   echo $i; done | RNG_test-musl-static stdin64 | tee -a test.log

# dmesg | head -c 8192 > dmesg.txt
# for i in $(seq 1 32); do echo $i; uchaos -i 16 -d 3 -r 31 -qM 16 < dmesg.txt;
#  done > test.dat; RNG_test-musl-static stdin64 < test.dat | tee -a test.log

if false; then
qemu-system-x86_64 \
  -append "console=ttyS0 root=/dev/vda acpi=off" \
  -drive file=rootfs.img,format=raw,id=hd0,if=none
  -device virtio-blk-device,drive=hd0 \

fi

