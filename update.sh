#!/bin/sh

# Contexts:
#  gke_ompldr_us-east4-a_ompldr-us-east4
#  gke_ompldr_us-west1-a_ompldr-us-west1

kubectl --context=gke_ompldr_us-east4-a_ompldr-us-east4 apply -f us-east4-macaroons.yaml
kubectl --context=gke_ompldr_us-east4-a_ompldr-us-east4 apply -f lnd-us-east4.yaml
kubectl --context=gke_ompldr_us-east4-a_ompldr-us-east4 apply -f bitcoind-us-east4.yaml

kubectl --context=gke_ompldr_us-west1-a_ompldr-us-west1 apply -f us-west1-macaroons.yaml
kubectl --context=gke_ompldr_us-west1-a_ompldr-us-west1 apply -f lnd-us-west1.yaml
kubectl --context=gke_ompldr_us-west1-a_ompldr-us-west1 apply -f bitcoind-us-west1.yaml

for ctx in $(kubectl config get-contexts --kubeconfig=./zpkubeconfig -o name); do
  kubectl --context="${ctx}" apply -f ssl-certs.yaml
  kubectl --context="${ctx}" apply -f secrets.yaml
  kubectl --context="${ctx}" apply -f api-server.yaml
  kubectl --context="${ctx}" apply -f periodic-service.yaml
  kubectl --context="${ctx}" apply -f invoice-service.yaml
  kubectl --context="${ctx}" apply -f web.yaml
done
