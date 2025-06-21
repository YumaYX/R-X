---
layout: post
title: Virtual KVM Console
category: "Virtualization"
---

Use a web console to manage KVM virtual machines. Make sure the KVM environment is set up beforehand.

```sh
dnf -y install cockpit-machines
systemctl enable --now cockpit.socket
```

# For Use in Local Environments Only

```sh
dnf -y install firewalld
firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload
firewall-cmd --list-all
```

1. Open your browser and go to `http://hostname:9090/`.
2. Log in as a regular user.
3. Select `System` → `Virtual Machines`.

To use administrator privileges, click `Restricted Access`.

Publishing this publicly is very risky.
