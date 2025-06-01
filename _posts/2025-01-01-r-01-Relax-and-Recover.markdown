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
BACKUP_URL="nfs://192.168.100.2/nfs/"

BACKUP_PROG_EXCLUDE=("${BACKUP_PROG_EXCLUDE[@]}" '/media' '/vat/tmp' '/var/crash' '/kdump')
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
rear -v mkbackup
```

検証中ため、以上。
