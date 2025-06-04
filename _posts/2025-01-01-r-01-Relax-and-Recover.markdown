---
layout: post
title: Relax-and-Recover
category: "Backup/Restore"
---

# Install Packages

```sh
dnf -y update
dnf -y install rear nfs-utils grub2-efi-x64-modules grub2-tools-extra
```

# Backup

## with NFS Server

```sh
cp -pv /etc/rear/local.conf /etc/rear/local.conf.bak

cat <<'EOF' > /etc/rear/local.conf
OUTPUT=ISO
BACKUP=NETFS
BACKUP_URL="nfs://192.168.11.42/nfs/"

BACKUP_PROG_EXCLUDE=("${BACKUP_PROG_EXCLUDE[@]}" '/media' '/var/tmp' '/var/crash' '/kdump')
LOGFILE="$LOG_DIR/rear-$HOSTNAME.log"
GRUB_RESCUE=1
EOF
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
rear -v mkbackup; echo ${?}
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

## NFS Server

```sh
# @host machine
# Build NFS Server
dnf -y update
dnf -y install nfs-utils firewalld


nfs_dir=/nfs
mkdir -p ${nfs_dir}
#echo "${nfs_dir} 192.168.122.0/24(rw,async,no_root_squash)" > /etc/exports
echo "${nfs_dir} *(rw,async,no_root_squash)" > /etc/exports

exportfs -ra

systemctl enable --now rpcbind nfs-server firewalld
systemctl restart rpcbind nfs-server firewalld
firewall-cmd --add-service=nfs --permanent

# libvirtの時は、interface virbr0から通信が入ってくる。
firewall-cmd --zone=libvirt --add-service=nfs --permanent

firewall-cmd --reload

firewall-cmd --list-all
firewall-cmd --zone=libvirt --list-all
```




## target machine

```sh
cat << 'KICKSTART' > /tmp/ks.cfg
text
reboot
cdrom

keyboard --vckeymap=jp106 --xlayouts='jp','us'
# keyboard --vckeymap=us --xlayouts='us','jp'
lang en_US.UTF-8

network --bootproto=dhcp --ipv6=auto --activate --hostname=localhost
zerombr

%packages
@core
%end

ignoredisk --only-use=vda
autopart
clearpart --all --initlabel

timezone Asia/Tokyo --utc

rootpw --iscrypted --allow-ssh $6$EkGHWaJKwbybILqx$DwIwbw5NOGm2LpNlaCIRCeckcOlHACxMMfsyYijZ0uEKmGTHmDSqQhs4ndUGpme5uZl7zg/aJyam8j9N6wWRG.
KICKSTART
```

ディストリビューションを/tmpにダウンロードしておく。

```sh
isouri='https://repo.almalinux.org/almalinux/10/isos/x86_64/AlmaLinux-10.0-x86_64-minimal.iso'
cd /tmp ; curl -O "${isouri}"
```

```sh
#osinfo-query os | grep -E "rhel[1|9]"

isouri=$(ls -1 /tmp/AlmaLinux-10* | head -n1)

virt-install \
  --name guest1-rhx \
  --memory 2048 \
  --vcpus 2 \
  --network default \
  --disk size=20 \
  --location "${isouri}" \
  --os-variant rhel10.0 \
  --graphics none \
  --accelerate \
  --initrd-inject /tmp/ks.cfg \
  --extra-args "console=tty0 console=ttyS0,115200n8 inst.ks=file:/ks.cfg"
```

1. login
1. backup with rear
1. `ctrl` + `]`

```sh
# @host machine and target machine
isofile='/tmp/rear.iso'
cp -pv /nfs/localhost/rear-localhost.iso ${isofile}

virsh list --all
virsh shutdown guest1-rhxr
virsh destroy guest1-rhxr
virsh undefine guest1-rhxr

qemu-img create -f qcow2 /var/lib/libvirt/images/guest1-rhxr.qcow2 30G
cat <<'EOF' > guest1-rhxr.xml
<domain type='kvm'>
  <name>guest1-rhxr</name>
  <memory unit='MiB'>4096</memory>
  <vcpu>2</vcpu>
  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
　  <boot dev='cdrom'/>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-passthrough'/>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>

<disk type='file' device='cdrom'>
  <driver name='qemu' type='raw'/>
  <source file='/tmp/rear.iso'/>
  <target dev='vdb' bus='sata'/>
  <readonly/>
</disk>

    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/guest1-rhxr.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>

    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
    <graphics type='vnc' port='-1' listen='127.0.0.1'/>
    <console type='pty'/>
  </devices>
</domain>
EOF

virsh define guest1-rhxr.xml
virsh start guest1-rhxr
virsh console guest1-rhxr
```

1. restore with rear
1. `ctrl` + `]`

```sh
reset
virsh detach-disk guest1-rhxr vdb --config
virsh shutdown guest1-rhxr

virsh start guest1-rhxr
virsh console guest1-rhxr

# check
# ctrl + ]

reset
# stop vm(clean)
virsh list --all
for v in guest1-rhxr guest1-rhx
do
  virsh shutdown ${v}
  virsh destroy ${v}
  virsh undefine ${v}
  virsh undefine ${v} --remove-all-storage
done
virsh list --all
```
