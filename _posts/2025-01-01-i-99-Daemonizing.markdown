---
layout: post
title: Daemonizing
category: "Service"
---

To run a simple shell script continuously in the background, it is convenient to register it as a systemd service. Here, as an example, we create a script at `/opt/hello.sh` that writes "hello world" to a log file every second, and manage it via systemd.

Also, when SELinux is enabled, placing the script under `/tmp` may cause it to lack the proper context and prevent execution via systemd. By placing the script under `/opt`, the `usr_t` label is applied, allowing it to run without issues.

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

If the script is located in `/tmp`, SELinux may prevent its execution. When placed in `/opt` as shown below, the `usr_t` label is applied, allowing it to be properly called from a systemd service.

```
[root@localhost ~]# ls -Z /opt/hello.sh
unconfined_u:object_r:usr_t:s0 /opt/hello.sh
[root@localhost ~]#
```

By writing `ExecStart=/usr/bin/sh -c <Shell>`, you don’t need to worry about the SELinux context.

##### Reference

- <https://qiita.com/DQNEO/items/0b5d0bc5d3cf407cb7ff>
- <https://www.yo7612.com/archives/148>
