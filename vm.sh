#!/bin/bash
#
# origin: https://github.com/dumbnerd08/SimpleQEMUx86/tree/main
# author: dumbnerd08
# license: GPL v2
#
# SimpleQEMUx86
#
# A simple QEMU-x86_64 CLI script that allows anyone to take advantage of the
# high performance of QEMU+KVM without the burden of VMM or other software.
# 
# The software is in its early stages, so please do not try to poke holes in it
# or mess it up. Thank you. The HDD size is in gigabytes and the RAM size is in
# megabytes. Please only type numbers. The number of CPUs maxes out at 255. When
# loading a CDROM/iso/img, please input the whole path from the / directory OR if
# the file is in the directory of the script, you can input a relative directory.
#
# Installation
#
# 1. Place the .sh file into a directory of your choice. We recommend you create
# a new folder somewhere in your system, but you don't have to. Then, open the
# script. That's all. No installation, no binaries, none of that. To run: navigate
# to the directory of the script and then type ./(the name of the script, vm.sh by
# default) You may have to go into the directory and type sudo chmod +rwx (the
# name of the script) to run it.
#
# Enjoy!
#
################################################################################

cd virtual-machines || mkdir virtual-machines; cd virtual-machines
read -p "Welcome! Press 1 to create a new virtual machine or 2 to load an existing virtual machine: " menu
if [ $menu -eq 1 ]
then
read -p "Name of your new virtual machine: " name
mkdir $name
cd $name
read -p "Hard drive size (GB): " hdasize
qemu-img create -f qcow2 "${name}.img" "${hdasize}G"
read -p "Number of CPUs: " cpus
read -p "Amount of RAM (MB): " ramsize
read -p "Path to your CDROM image or ISO, from / (including suffix: iso, img, etc.): " cdrompath
qemu-system-x86_64 -enable-kvm -cpu host -machine accel=kvm -smp $cpus -boot order=dc -m "${ramsize}M" -cdrom $cdrompath -hda ${name}.img -name $name & echo "VM loaded successfully. Exiting terminal.";sleep 3;exit
elif [ $menu -eq 2 ]
then
	ls	
	read -p "Input the name of your virtual machine listed above: " vmname
	cd $vmname
	read -p "Number of CPUs: " cpus
read -p "Amount of RAM (MB): " ramsize
	qemu-system-x86_64 -enable-kvm -cpu host -machine accel=kvm -smp $cpus -m "${ramsize}M" -hda ${vmname}.img -name $vmname & echo "VM loaded successfully. Exiting terminal.";sleep 3;exit
else
	echo "I don't believe that you followed the instructions. You will receive another chance, but heed this warning."
	./$0
	sleep 1
	exit
fi
