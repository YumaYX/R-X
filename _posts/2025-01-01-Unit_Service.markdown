---
layout: post
title: Daemonizing
category: "Unit Service"
---

```sh
cat <<'EOFSH' > /opt/hello.sh
#!/bin/bash
while true
do
  echo hello world >> /tmp/hello.log
  sleep 1
done
EOFSH

chmod 744 /opt/hello.sh


cat <<'EOFSERVICE' > /etc/systemd/system/hello.service
[Unit]
Description = hello daemon

[Service]
ExecStart = /opt/hello.sh
Restart = always

[Install]
WantedBy = multi-user.target
EOFSERVICE

# setting
systemctl enable hello --now
systemctl start hello

# check
sleep 3 ; tail -F /tmp/hello.log
```

# Note on SELinux Contexts

When created under /tmp, the shell does not execute due to different SELinux labels. It worked when created under /opt (usr_t).

```
[root@localhost ~]# ls -Z /opt/hello.sh
unconfined_u:object_r:usr_t:s0 /opt/hello.sh
[root@localhost ~]#
```

##### Reference

<https://qiita.com/DQNEO/items/0b5d0bc5d3cf407cb7ff>

