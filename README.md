# born2beroot

Ok, I hate the idea of having to setup everything manually from VirtualBox, let's be smarter and find a reproducible and automated way of doing this task. 

We can create a file using dd, use losetup to create a device from it, use fdisk to create partitions on it, configure those partitions. Then use debootstrap to install debian. Then we can just convert the file created with dd to a VDI file. 

dd if=/dev/zero of=disk.img bs=1M count=2048
sudo losetup -fP disk.img
# check
losetup -a
sudo fdisk /dev/loop
# just create a primary partition that takes the full size
sudo mkfs.ext4 /dev/loop0p1 
sudo mount /dev/loop0p1 /mnt
sudo debootstrap --arch amd64 stable /mnt https://deb.debian.org/debian 

sudo mount --make-rslave --rbind /proc /mnt/proc
sudo mount --make-rslave --rbind /sys /mnt/sys
sudo mount --make-rslave --rbind /dev /mnt/dev
sudo mount --make-rslave --rbind /run /mnt/run
sudo chroot /mnt /bin/bash

## Resources

- https://wiki.archlinux.org/title/LVM
- https://wiki.archlinux.org/title/SELinux
- https://wiki.archlinux.org/title/Uncomplicated_Firewall
