---
layout: post
title: Auto Connection 
category: "Networking"
---

AlmaLinux 10 でネットワーク接続を常に自動で有効化させたい場合は、以下のコマンドを実行することで簡単に設定できます。

# Auto Connect Setting

```sh
nmcli c | grep -v ^NAME | awk '{print $1}' | xargs -I@ nmcli c mod @ connection.autoconnect yes
```

このコマンドは、すべてのネットワーク接続に対して「自動接続（autoconnect）」を有効にするものです。
nmcli c で接続名一覧を取得し、ヘッダー（NAME 行）を除外した上で、各接続の UUID または名前を抽出し、それぞれに対して connection.autoconnect yes を設定しています。