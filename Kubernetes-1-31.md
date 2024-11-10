# Kubernetes 1.31

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
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

```sh
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

```sh
sudo touch /etc/systemd/zram-generator.conf
sudo dnf remove -y zram-generator-defaults
```

> Reboot

```sh
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
```

```sh
sudo dnf install -y kubelet kubeadm kubectl
```

```sh
sudo dnf config-manager setopt kubernetes.enabled=0
```

```sh
sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.backup
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false$/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's/registry.k8s.io\/pause:3.8/registry.k8s.io\/pause:3.10/' /etc/containerd/config.toml
```

```sh
sudo systemctl enable --now containerd
sudo systemctl enable --now kubelet
```

```sh
sudo kubeadm init --config /dev/stdin <<EOF
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta4
kubernetesVersion: v1.31.0
networking:
  podSubnet: "10.0.0.0/8"
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
EOF
```

```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```sh
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/calico.yaml
```

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

```sh
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl label nodes --all node.kubernetes.io/exclude-from-external-load-balancers-
```

```sh
curl -L https://github.com/projectcalico/calico/releases/download/v3.29.0/calicoctl-linux-amd64 -o kubectl-calico
sudo install -o root -g root -m 0755 kubectl-calico /usr/local/bin/kubectl-calico
```

```sh
curl -LO https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar -zxvf helm-v3.16.2-linux-amd64.tar.gz linux-amd64/helm --strip-components=1
sudo install -o root -g root -m 0755 helm /usr/local/bin/helm
```

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
