#!/bin/sh
# (c) 2026, Roberto A. Foglietta <roberto.foglietta@gmail.com>, MIT license

action=${1:-}
cpiofl=${2:-initramfs.cpio.gz}
tmpdir=${3:-cpio.tmp}

zcmd="gzip"; which pigz >/dev/null && zcmd="pigz"

if [ "x$action" = "x-e" ]; then
    mkdir -p $tmpdir
    zcat $cpiofl | cpio -idmv -D $tmpdir
elif [ "x$action" = "x-c" ]; then
    rm -f $cpiofl
    cd $tmpdir
    find . | cpio -o -H newc | $zcmd -c > ../$cpiofl
    cd - >/dev/null
    du -ks $cpiofl | sed -e "s/\t/ Kb /"
else
    echo
    echo "Usage: cpio.sh -e|-c file dir"
    echo
fi
