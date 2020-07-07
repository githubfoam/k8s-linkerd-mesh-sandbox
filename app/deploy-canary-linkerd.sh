#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://linkerd.io/2/getting-started/
echo "============================Install Linkerd=============================================================="
curl -sL https://run.linkerd.io/install | sh

export PATH=$PATH:$HOME/.linkerd2/bin
linkerd dashboard &

echo "============================Linkerd Flagger Canary Deployments=============================================================="
kubectl get pods --all-namespaces
kubectl create ns linkerd #Create a namespace called Linkerd

#Install Flagger in the linkerd namespace
kubectl apply -k github.com/weaveworks/flagger//kustomize/linkerd
echo echo "Waiting for flagger to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=kube-system  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done
kubectl get pods --all-namespaces


# Bootstrap
# Flagger takes a Kubernetes deployment and optionally a horizontal pod autoscaler (HPA)
# creates a series of objects (Kubernetes deployments, ClusterIP services and SMI traffic split)
# objects expose the application inside the mesh and drive the canary analysis and promotion


# Create a test namespace and enable Linkerd proxy injection
kubectl create ns test
kubectl annotate namespace test linkerd.io/inject=enabled

kubectl get pods --all-namespaces
# Install the load testing service to generate traffic during the canary analysis
kubectl apply -k github.com/weaveworks/flagger//kustomize/tester
echo echo "Waiting for flagger to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=test  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done
kubectl get pods --all-namespaces

# Create a deployment and a horizontal pod autoscaler
kubectl apply -k github.com/weaveworks/flagger//kustomize/podinfo
echo echo "Waiting for flagger to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=test  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done
kubectl get pods --all-namespaces

# Create a canary custom resource for the podinfo deployment
kubectl apply -f app/podinfo-canary.yaml
