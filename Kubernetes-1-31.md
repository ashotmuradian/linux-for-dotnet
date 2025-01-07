# Kubernetes 1.31

```sh
# https://kubernetes.io/docs/reference/networking/ports-and-protocols/

sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10256/tcp
sudo firewall-cmd --permanent --add-port=10257/tcp
sudo firewall-cmd --permanent --add-port=10259/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
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
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

```sh
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/calico.yaml
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
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
```

```sh
curl -LO https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar -zxvf helm-v3.16.2-linux-amd64.tar.gz linux-amd64/helm --strip-components=1
sudo install -o root -g root -m 0755 helm /usr/local/bin/helm
```

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

```sh
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard | tee ./kubernetes-dashboard.md
```

```sh
kubectl apply -f /dev/stdin <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f /dev/stdin <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f /dev/stdin <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token
EOF

kubectl apply -f /dev/stdin <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15;
do
sudo mkdir -p /mnt/d/kubernetes/local-pv-$i
sudo chmod 777 /mnt/d/kubernetes/local-pv-$i
kubectl apply -f /dev/stdin <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-$i
spec:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: local-storage
  hostPath:
    path: /mnt/d/kubernetes/local-pv-$i
    type: Directory
EOF
done
```

--------------------------------

## Dashboard

```sh
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

### Getting a Bearer Token for ServiceAccount

```sh
kubectl -n kubernetes-dashboard create token admin-user
```

### Getting a long-lived Bearer Token for ServiceAccount

```sh
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

--------------------------------

## Infra

> Note: if you need a Redis cluster use the `redis-cluster` chart instead of the `redis` char below.

```sh
helm upgrade --install rabbitmq bitnami/rabbitmq -f /dev/stdin <<EOF
service:
  type: LoadBalancer
EOF
helm get notes rabbitmq | tee kubernetes-rabbitmq.md

helm upgrade --install redis bitnami/redis -f /dev/stdin <<EOF
master:
  service:
    type: LoadBalancer
    # nodePorts:
    #   redis: '30379'
replica:
  service:
    type: LoadBalancer
    # nodePorts:
    #   redis: '30380'
sentinel:
  service:
    type: LoadBalancer
  masterService:
    type: LoadBalancer
metrics:
  service:
    type: LoadBalancer
EOF
helm get notes redis | tee kubernetes-redis.md


helm upgrade --install postgresql bitnami/postgresql -f /dev/stdin <<EOF
primary:
  service:
    type: LoadBalancer
readReplicas:
  service:
    type: LoadBalancer
image:
  tag: 11
EOF
helm get notes postgresql | tee kubernetes-postgresql.md

helm upgrade --install kafka bitnami/kafka -f /dev/stdin <<EOF
externalAccess:
  enabled: true
  autoDiscovery:
    enabled: true
  controller:
    service:
      type: LoadBalancer
    domain: localhost
  broker:
    service:
      type: LoadBalancer
    domain: localhost
serviceAccount:
  create: true
rbac:
  create: true
controller:
  automountServiceAccountToken: true
broker:
  automountServiceAccountToken: true
EOF
helm get notes kafka | tee kubernetes-kafka.md

helm upgrade --install cert-manager jetstack/cert-manager -f /dev/stdin <<EOF
crds:
  enabled: true
EOF
helm get notes cert-manager | tee kubernetes-cert-manager.md

helm upgrade --install zipkin bitnami/zipkin -f /dev/stdin <<EOF
storageType: mem
cassandra:
  enabled: false
EOF
helm get notes zipkin | tee kubernetes-zipkin.md

helm upgrade --install otel-collector open-telemetry/opentelemetry-collector -f /dev/stdin <<EOF
mode: daemonset
image:
  repository: otel/opentelemetry-collector-k8s
presets:
  kubernetesAttributes:
    enabled: true
  kubeletMetrics:
    enabled: true
  logsCollection:
    enabled: true
# config:
#   exporters:
#     otlp:
#       endpoint: "<SOME BACKEND>"
#   service:
#     pipelines:
#       traces:
#         exporters: [ otlp ]
#       metrics:
#         exporters: [ otlp ]
#       logs:
#         exporters: [ otlp ]
EOF
helm get notes otel-collector | tee kubernetes-otel-collector.md

helm upgrade --install otel-collector-cluster open-telemetry/opentelemetry-collector -f /dev/stdin <<EOF
mode: deployment
image:
  repository: otel/opentelemetry-collector-k8s
replicaCount: 1
presets:
  clusterMetrics:
    enabled: true
  kubernetesEvents:
    enabled: true
# config:
#   exporters:
#     otlp:
#       endpoint: "<SOME BACKEND>"
#   service:
#     pipelines:
#       traces:
#         exporters: [ otlp ]
#       metrics:
#         exporters: [ otlp ]
#       logs:
#         exporters: [ otlp ]
EOF
helm get notes otel-collector-cluster | tee kubernetes-otel-collector-cluster.md
```

```sh
sudo firewall-cmd --permanent --add-port=6379/tcp
```

```sh
sudo systemctl stop firewalld
```

## Registry and Data Directories

> To move existing data of `docker` and `containerd` use the following:
> ```sh
> sudo systemctl stop kubelet containerd docker
> sudo rsync -aP /var/lib/docker/ /mnt/d/docker
> sudo rsync -aP /var/lib/containerd/ /mnt/d/containerd/root
> sudo rsync -aP /run/containerd/ /mnt/d/containerd/state
> sudo chown -R root:root /mnt/d/docker
> sudo chown -R root:root /mnt/d/containerd/root
> sudo chown -R root:root /mnt/d/containerd/state
> ```
> And reboot.

```sh
docker run -d -p 5000:5000 --restart always --name registry registry:2
```

```sh
cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "data-root": "/mnt/d/docker",
    "insecure-registries": ["127.0.0.1:5000"]
}
EOF
```

```toml
# /etc/containerd/config.toml

root = "/mnt/d/containerd/root"
state = "/mnt/d/containerd/state"
```

```toml
# /etc/containerd/config.toml

[grpc]
  address = "/mnt/d/containerd/containerd.sock"
```

```toml
# /etc/containerd/config.toml

[plugins."io.containerd.grpc.v1.cri".registry.configs."127.0.0.1:5000"]

[plugins."io.containerd.grpc.v1.cri".registry.configs."127.0.0.1:5000".tls]
  insecure_skip_verify = true
```

```toml
# /etc/containerd/config.toml

[plugins."io.containerd.grpc.v1.cri".registry.mirrors."127.0.0.1:5000"]
  endpoint = ["http://127.0.0.1:5000"]
```

```sh
sudo systemctl restart docker containerd kubelet
```
