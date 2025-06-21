---
layout: post
title: Samba Server
category: "Service"
---

# Build a Samba Server

This guide explains how to build a Samba server to share files over the network.

## Assumed Environment

- Samba Server: 192.168.11.123  
    - Network: 192.168.11.0/24  
    - Shared Directory: /samba/share  
    - User: vagrant  
        - Assumes the system user and home directory already exist.

## Mount User and Shared Directory

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

## Deleting a User

To delete a specific user from the local `smbpasswd` file:

```sh
smbpasswd -x ${user}
```

## Connection Test

Install the necessary client packages on the client machine, then access the shared folder.

### Test by hand

```sh
dnf -y install samba-client
smbclient //192.168.11.123/share
```

### Test 2

When mounting on Linux, it is recommended to assign permissions to a regular user by specifying `uid` and `gid`.


```sh
dnf -y install cifs-utils
# Match uid and gid to the user
sudo mount -t cifs -o username=vagrant,password=vagrant,uid=1000,gid=1000 '//192.168.11.123/Share' /media ; echo $?
```

#### Mount Command Details

```sh
# mount -t cifs [-o <options>] //<server>/<shared folder> <mount point>
```

- Server: IP address or server name  
- Shared folder name: The **shared folder name** as defined in the samba.conf section header  
- Mount point: Any directory of your choice  
- `-o`: Options

If you mount as root, regular users will not be able to write, so add `uid` and `gid` options. The same applies for guest users.

### About the Label of the Share Directory

When running `semanage` or `restorecon` again, the SELinux security context label of the files may change. Below is the state required for the directory to be used as a file server. The type being `samba_share_t` indicates it is shared via Samba.

```
[root@localhost ~]# ls -1RZ /samba
/samba:
unconfined_u:object_r:samba_share_t:s0 share

/samba/share:
system_u:object_r:samba_share_t:s0 share
[root@localhost ~]# 
```

# Connecting from Mac

- Finder -> Go -> Connect to Server... (⌘+K)

## URI to connect

```sh
smb://vagrant:vagrant@192.168.11.123
```

```sh
cifs://vagrant:vagrant@192.168.11.123
```

```sh
cifs://vagrant:vagrant@192.168.11.123/Share
```

# Connecting from Windows 11

Using Command Prompt

```bat
net use r: \\192.168.11.123\Share vagrant /user:vagrant
```
