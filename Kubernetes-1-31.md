## Open Ports in Firewall
```sh
# https://kubernetes.io/docs/reference/networking/ports-and-protocols/

sudo firewall-cmd --add-port=6443/tcp
sudo firewall-cmd --add-port=10250/tcp
sudo firewall-cmd --add-port=10256/tcp
sudo firewall-cmd --add-port=10257/tcp
sudo firewall-cmd --add-port=10259/tcp
sudo firewall-cmd --add-port=2379-2380/tcp
sudo firewall-cmd --add-port=30000-32767/tcp
```
```sh
# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

> Reboot
