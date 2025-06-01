---
layout: post
title: "Disk Addition and Initialization"
category: "Disk"
---

追加ディスク /dev/vdb を ext4 でフォーマットし、マウント・自動マウントする方法を説明します。ディスクの初期化からマウント、永続設定（fstab）までを一通り実行します。

現在のブロックデバイス（ディスク）の構成を確認します。vdb が存在することを確認します。

```sh
lsblk
```

/dev/vdb に GPT パーティションテーブルを作成し、全領域を使って ext4 用のパーティション /dev/vdb1 を作成します。再度 lsblk を実行して /dev/vdb1 が作成されているか確認します。

作成したパーティション /dev/vdb1 を ext4 ファイルシステムでフォーマットします。

```sh
parted /dev/vdb --script mklabel gpt mkpart primary ext4 0% 100%
lsblk

mkfs -t ext4 /dev/vdb1
```

# mount

マウントポイント /mnt に /dev/vdb1 を一時的にマウントします。ls /mnt を実行して中身が空であることを確認します。
df -h でマウント状況と空き容量を確認します。fallocate を使って /mnt/dummy に1GBの空ファイルを作成し、ディスク使用量の変化を確認します。

```sh
touch /mnt/empty
mount /dev/vdb1 /mnt
ls /mnt
df -h
fallocate -l 1G /mnt/dummy
df -h
```

作業が終わったら、マウントを解除します。

```sh
umount /mnt
```

# auto mount

blkid で取得した /dev/vdb1 の UUID を /etc/fstab に書き込み、自動マウントを設定します。
これにより、次回起動時に /mnt に自動でマウントされるようになります。

```sh
echo "$(blkid /dev/vdb1 | sed 's/ /\n/g' | grep ^UUID) /mnt ext4 defaults,nofail 0 1" >> /etc/fstab
```
