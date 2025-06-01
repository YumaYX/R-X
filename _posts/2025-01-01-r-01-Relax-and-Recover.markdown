---
layout: post
title: Relax-and-Recover
category: "Backup/Restore"
---

**<u>注意：未検証</u>**

# Install Packages

```sh
dnf -y update
dnf -y install rear grub2-efi-x64-modules grub2-tools-extra
```

# Backup

## with NFT Server

```sh
cp /etc/rear/local.conf /etc/rear/local.conf.bak

cat <<'EOF' > /etc/rear/local.conf
OUTPUT=ISO
BACKUP=NETFS
BACKUP_URL="nfs://192.168.122.249/nfs/"

BACKUP_PROG_EXCLUDE=("${BACKUP_PROG_EXCLUDE[@]}" '/media' '/vat/tmp' '/var/crash' '/kdump')
LOGFILE="$LOG_DIR/rear-$HOSTNAME.log"
GRUB_RESCUE=1
EOF

mkdir -p /backup && umount /backup
mount -t nfs 192.168.122.249:/nfs /backup
```

## on Local

```sh
cat <<'EOF' > /etc/rear/local.conf
OUTPUT=ISO
OUTPUT_URL=file:///backup
BACKUP=NETFS
BACKUP_URL=file:///backup

BACKUP_PROG_EXCLUDE=("${BACKUP_PROG_EXCLUDE[@]}" '/media' '/var/tmp' '/var/crash' '/kdump' '/backup')
LOGFILE="$LOG_DIR/rear-$HOSTNAME.log"
GRUB_RESCUE=1
EOF
```

### 注意

`/backup`は、`/`と別デバイスにすること：

```
ERROR: URL 'file:///backup' has the backup directory '/backup' in the '/' filesystem which is forbidden.
```
のエラーが発生する。

## Start Backup

```sh
rear -v mkbackup
```

# Restore

1. レスキューシステムを取り出す(ISOファイル、DVD、USBとして書き出す) 。
1. レスキューシステムより、ブートする。
1. “Recover hostname“を選択する。
1. ログインプロンプトが出たら、rootと入力する。

```sh
ip a

# DHCPがあるネットワークであれば不要(IPアドレスが取得できていれば不要)
ip addr add 192.168.122.250/24 dev <network interface>
```

リストアを進める。途中に出てくる対話には、基本的に1を答える。

```sh
rear recover
reboot
```

再起動が2回実施されるため、待つ。

---

# Build Env.

```sh
isouri=$(ls -1 /tmp/AlmaLinux-10* | head -n1)

virt-install \
  --name guest1-rhx \
  --memory 2048 \
  --vcpus 2 \
  --network default \
  --disk size=20 \
  --location "${isouri}" \
  --os-variant rhel9.4 \
  --graphics none \
  --accelerate \
  --initrd-inject /tmp/ks.cfg \
  --extra-args "console=tty0 console=ttyS0,115200n8 inst.ks=file:/ks.cfg"
```

```sh
# @ virtual machine
#virsh console guest1-rhx

ip a #=> 192.168.122.249

# Build NFS Server
dnf -y update
dnf -y install nfs-utils firewalld

nfs_dir=/nfs
mkdir -p ${nfs_dir}
echo "${nfs_dir} 192.168.122.0/24(rw,no_root_squash)" > /etc/exports
# echo "${nfs_dir} *(rw,no_root_squash)" > /etc/exports

exportfs -ra

systemctl enable --now rpcbind nfs-server firewalld
systemctl restart rpcbind nfs-server firewalld
firewall-cmd --add-service=nfs --permanent
firewall-cmd --reload
```

```sh
cp -pv /nfs/xxxx.iso /tmp/rear.iso
umount /backup
isofile='/tmp/rear.iso'

virt-install \
  --name guest1-rhxbk \
  --memory 2048 \
  --vcpus 2 \
  --network default \
  --disk size=20 \
  --location "${isofile}" \
  --os-variant rhel9.4 \
  --graphics none \
  --extra-args "console=tty0 console=ttyS0,115200n8"

# Resore

# stop vm(clean)
virsh list --all
virsh shutdown guest1-rhx
virsh destroy guest1-rhx
virsh undefine guest1-rhx --remove-all-storage 
```
