#!/usr/bin/env bash

# Install K3S using Docker as it's container runtime
curl -sfL https://get.k3s.io | sh -s - --docker 

# Fetch kubeconfig
mkdir ~/.kube || echo "~/.kube already exists"
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

# ensure that node is created
timeout 2m bash -c 'until kubectl get node $HOSTNAME; do sleep 1; done'

# ensure node is actually ready
kubectl wait --timeout=120s --for=condition=Ready node/$HOSTNAME

# wait until default serviceaccount is provisioned
timeout 2m bash -c 'until kubectl get serviceaccount default; do sleep 1; done'

# wait for full cluster readyness
kubectl rollout status -n kube-system deployment/metrics-server
kubectl rollout status -n kube-system deployment/coredns
kubectl rollout status -n kube-system deployment/local-path-provisioner
