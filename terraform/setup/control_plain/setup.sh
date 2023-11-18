#!/bin/bash

# mount ebs volume
sudo mkfs -t ext4 /dev/nvme0n1
sudo mkdir -p /mnt/data
sudo mount /dev/nvme0n1 /mnt/data
echo '/dev/nvme0n1 /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y containerd kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl start containerd && sudo systemctl enable containerd

# sudo mkdir /etc/containerd
# sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo vi /etc/containerd/config.toml
# edit below
# [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#   SystemdCgroup = true
# [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
#   [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
#     endpoint = ["https://registry-1.docker.io"]

sudo systemctl restart containerd

sudo modprobe br_netfilter
echo "br_netfilter" | sudo tee /etc/modules-load.d/br_netfilter.conf

sudo vi /etc/sysctl.conf
# edit below
# net.ipv4.ip_forward=1
# net.bridge.bridge-nf-call-iptables=1
sudo sysctl -p

sudo mkdir /mnt/data/etcd
sudo kubeadm init --config kubeadm-config.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
