---
layout: post
title: Local Package Repository
category: "Packages"
---

Mount the installation media and configure it so the package repository can be used.

## Configuring the Package Repository for AlmaLinux

1. Back up the existing package repository reference files.
1.Set the installation media mount point as the new repository reference.
1.Mount the media to the /media directory.

```sh
cd /tmp
isouri='https://ftp.riken.jp/Linux/almalinux/10.0/isos/x86_64/AlmaLinux-10-latest-x86_64-dvd.iso'
isofile=$(basename ${isouri})

curl -O "${isouri}" &


cp -prv /etc/yum.repos.d/ /etc/yum.repos.d.bak
rm -rf /etc/yum.repos.d/*.repo

cat <<DVDREPO >/etc/yum.repos.d/dvd.repo
[BaseOS]
name=DVD-BaseOS
baseurl=file:///media/BaseOS/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-10

[AppStream]
name=DVD-AppStream
baseurl=file:///media/AppStream/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-10
DVDREPO

cat <<DVDMOUNT > /root/dvd_mount.sh
mount -o loop "/tmp/${isofile}" /media
#mount /dev/cdrom /media # for a physical media
DVDMOUNT

wait

sh /root/dvd_mount.sh
```

## Restoring the Original Repository References

```sh
rm -f /etc/yum.repos.d/dvd.repo
\cp -fpv /etc/yum.repos.d.bak/*.repo /etc/yum.repos.d/
```

#### Link

<https://ftp.riken.jp/Linux/almalinux/>