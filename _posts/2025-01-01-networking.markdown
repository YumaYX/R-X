---
layout: post
title: Networking 
category: "Networking"
---



```sh
nmcli c | grep -v ^NAME | awk '{print $1}' | xargs -I@ nmcli c mod @ connection.autoconnect yes
```
