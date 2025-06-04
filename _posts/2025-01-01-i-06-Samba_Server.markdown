---
layout: post
title: Samba Server
category: "Service"
---

Sambaサーバーを構築する。ネットワークを通して、ファイル共有をする。

# 想定環境

- Samba Server：192.168.11.123
    - ネットワーク：192.168.11.0/24
    - 共有ディレクトリ：/samba/share
    - ユーザ：vagrant
        - システムユーザおよび、ホームディレクトリが存在することを前提とする。

# Build a Samba Server

## マウントユーザーと、共有先ディレクトリ

```sh
user=vagrant
pass=vagrant
share_dir=/samba/share
```

## Install Packages and Setting

```sh
dnf -y update

# Firewall
dnf -y install firewalld
systemctl enable firewalld --now
firewall-cmd --permanent --zone=public --add-service=samba
firewall-cmd --reload

# Install Samba and Setting Conf.
dnf install -y samba samba-common
cp -pv /etc/samba/smb.conf /etc/samba/smb.conf.bak

cat <<SAMBACONF > /etc/samba/smb.conf
[global]
security = user
map to guest = Bad User
netbios name = linux
hosts allow = 192.168.11. 127.
mangled names = no
vfs objects = catia
catia:mappings = 0x22:0xa8,0x2a:0xa4,0x2f:0xf8,0x3a:0xf7,0x3c:0xab,0x3e:0xbb,0x3f:0xbf,0x5c:0xff,0x7c:0xa6
unix charset = UTF-8
dos charset = cp932
read only = no
writeable = yes
force create mode = 0644
force directory mode = 0755
passdb backend = tdbsam

[Share]
path = ${share_dir}
valid users = ${user}
SAMBACONF

#pdbedit -a -u ${user}
(echo "${pass}"; echo "${pass}") | smbpasswd -a -s ${user}

# Setting of Directories
yum install -y policycoreutils-python-utils

mkdir -p ${share_dir}
install -m 0777 -o nobody -g nobody -d ${share_dir}
for ea in $(find $(dirname ${share_dir}))
do
  semanage fcontext -a -t samba_share_t ${ea}
done
restorecon -Rv $(dirname ${share_dir})
ls -1RZ $(dirname ${share_dir})

systemctl enable  smb.service nmb.service
systemctl restart smb.service nmb.service
```

### delete user

ユーザーを削除する場合

```sh
# 指定したユーザー userをローカルのsmbpasswdファイルから削除することを指示
smbpasswd -x ${user}
```

## Connection Test

クライアントのインストールを実施し、その後、共有フォルダへアクセスする。

### Test by hand

```sh
dnf -y install samba-client
smbclient //192.168.11.123/share
```

### Test 2

Linux上でマウントする際は、一般ユーザに権限を与える形(uid,gidを指定)する形をおすすめする。

```sh
dnf -y install cifs-utils
# uid,gidはユーザに合わせる
sudo mount -t cifs -o username=vagrant,password=vagrant,uid=1000,gid=1000 '//192.168.11.123/Share' /media ; echo $?
```

#### マウントコマンド詳細

```sh
# mount -t cifs [-o <options>] //<接続先>/<共有フォルダ名> <マウント先>
```

- 接続先：IPアドレス、サーバ名
- 共有フォルダ名：samba.confの中で、**<u>見出しの共有フォルダ名</u>**
- マウント先：任意のディレクトリ
- -o：オプション

rootでマウントすると、一般ユーザで書き込めないため、uid,gidをオプションに付加する。ゲストユーザも状況は同じである。

#### Connection Test

```sh
sudo mount -t cifs -o username=vagrant,password=vagrant,uid=1000,gid=1000 '//192.168.11.123/vagrant' /media
```

### Shareディレクトリのラベルについて

semanageまたは、restoreconを再度打鍵すると、ファイルのSELinuxセキュリティコンテキストラベルが変更される場合がある。以下にファイルサーバとして使用できる状態を示す。タイプが、samba_share_tになっていることが、Sambaへの共有を示す。

```
[root@localhost ~]# ls -1RZ /samba
/samba:
unconfined_u:object_r:samba_share_t:s0 share

/samba/share:
system_u:object_r:samba_share_t:s0 share
[root@localhost ~]# 
```

# Macからの接続

- Finder -> 移動 -> サーバへ移動...(⌘+k)

## 接続URI

```sh
smb://vagrant:vagrant@192.168.11.123
```

```sh
cifs://vagrant:vagrant@192.168.11.123
```

```sh
cifs://vagrant:vagrant@192.168.11.123/Share
```

# Windows 11からの接続

コマンドプロンプトにて

```bat
net use r: \\192.168.11.123\Share vagrant /user:vagrant
```
