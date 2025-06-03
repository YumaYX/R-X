---
layout: post
title: Virtual KVM Console
category: "Virtualization"
---

KVMの仮想マシンを管理するために、Webコンソールを使用する。事前にKVM環境を作成しておく。

```sh
dnf -y install cockpit-machines
systemctl enable --now cockpit.socket
```

# Local環境で使用する場合のみ

```sh
dnf -y install firewalld
firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload
firewall-cmd --list-all
```

1. ブラウザにて、`http://hostname:9090/`にアクセスする。
1. 一般ユーザーでログインする。
1. `システム`→`仮想マシン`を選択する。

管理者権限を使用する場合は、`制限付きアクセス`をクリックする。

これを公開するなんて、とっても危ないね。
