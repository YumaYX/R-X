---
layout: post
title: Local Package Repository
category: "Packages"
---

インストールメディアをマウントして、パッケージレポジトリを使用できるようにする。

# AlmaLinuxのパッケージレポジトリ設定

1. 既存のパッケージレポジトリ参照先ファイルを退避させる
1. インストールメディアのマウント先を、参照先とする
1. /mediaにマウントする。


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

# レポジトリ参照先を元に戻す場合

```sh
rm -f /etc/yum.repos.d/dvd.repo
\cp -fpv /etc/yum.repos.d.bak/*.repo /etc/yum.repos.d/
```

#### Link

<https://ftp.riken.jp/Linux/almalinux/>