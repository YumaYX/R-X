---
layout: post
title: "Disk Addition and Initialization"
category: "Disk"
---

This explains how to format an additional disk `/dev/vdb` with ext4, mount it, and set it up for automatic mounting. The process covers everything from disk initialization to mounting and persistent configuration (fstab).

First, check the current block device (disk) layout to confirm that `vdb` exists.

```sh
lsblk
```

Create a GPT partition table on `/dev/vdb` and create a partition `/dev/vdb1` for ext4 using the entire disk space. Run `lsblk` again to confirm that `/dev/vdb1` has been created.

Format the created partition `/dev/vdb1` with the ext4 filesystem.

```sh
parted /dev/vdb --script mklabel gpt mkpart primary ext4 0% 100%
lsblk

mkfs -t ext4 /dev/vdb1
```

# mount

Temporarily mount `/dev/vdb1` to the mount point `/mnt`. Run `ls /mnt` to confirm that the directory is empty.  
Use `df -h` to check the mount status and available space.  
Create a 1GB empty file `/mnt/dummy` using `fallocate` and verify the change in disk usage.


```sh
touch /mnt/empty
mount /dev/vdb1 /mnt
ls /mnt
df -h
fallocate -l 1G /mnt/dummy
df -h
```

After finishing the work, unmount the mount point.

```sh
umount /mnt
```

# Auto Mount

Write the UUID of `/dev/vdb1` obtained with `blkid` into `/etc/fstab` to configure automatic mounting.  
This ensures that `/mnt` will be automatically mounted at the next boot.

```sh
echo "$(blkid /dev/vdb1 | sed 's/ /\n/g' | grep ^UUID) /mnt ext4 defaults,nofail 0 1" >> /etc/fstab
```
