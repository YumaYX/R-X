---
layout: post
title: Auto Connection 
category: "Networking"
---

To always enable automatic network connection on AlmaLinux 10, you can easily configure it by running the following command:

## Auto Connect Setting

```sh
nmcli c | grep -v ^NAME | awk '{print $1}' | xargs -I@ nmcli c mod @ connection.autoconnect yes
```

This command enables the "autoconnect" setting for all network connections. It retrieves a list of connections using nmcli c, filters out the header line (NAME), extracts the UUIDs or names of each connection, and then sets connection.autoconnect yes for each one.
