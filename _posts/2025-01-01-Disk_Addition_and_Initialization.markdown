---
layout: post
title: "Disk Addition and Initialization"
category: "disk"
---

```sh
lsblk
```

```sh
parted /dev/vdb --script mklabel gpt mkpart primary ext4 0% 100%
lsblk

mkfs -t ext4 /dev/vdb1
```

# mount

```sh
touch /mnt/empty
mount /dev/vdb1 /mnt
ls /mnt
df -h
fallocate -l 1G /mnt/dummy
df -h

umount /mnt
```

# auto mount

```sh
echo "$(blkid /dev/vdb1 | sed 's/ /\n/g' | grep ^UUID) /mnt ext4 defaults,nofail 0 1" >> /etc/fstab
```

