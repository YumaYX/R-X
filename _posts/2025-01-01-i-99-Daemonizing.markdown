---
layout: post
title: Daemonizing
category: "Service"
---

簡単なシェルスクリプトをバックグラウンドで常時実行させるには、systemd サービスとして登録するのが便利です。ここでは、1 秒ごとに "hello world" をログファイルに書き込むスクリプトを /opt/hello.sh に作成し、systemd を通じて起動・管理する例を示しています。

また、SELinux が有効な状態では、スクリプトを /tmp 以下に配置すると適切なコンテキストが付かず、systemd 経由で実行できない場合があります。スクリプトを /opt に配置することで usr_t ラベルが適用され、問題なく動作します。

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

スクリプトが /tmp にあると SELinux によって実行が拒否されることがあります。以下のように /opt に配置した場合は、usr_t のラベルが付き、正常に systemd サービスから呼び出すことができます。

`ExecStart=/usr/bin/sh-c <Shell>`の形で記述すれば、SELinuxコンテキストの考慮は不要となる。

```
[root@localhost ~]# ls -Z /opt/hello.sh
unconfined_u:object_r:usr_t:s0 /opt/hello.sh
[root@localhost ~]#
```

##### Reference

- <https://qiita.com/DQNEO/items/0b5d0bc5d3cf407cb7ff>
- <https://www.yo7612.com/archives/148>
