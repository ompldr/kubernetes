#!/bin/sh

# Contexts:
#  gke_ompldr_us-east4-a_ompldr-us-east4
#  gke_ompldr_us-west1-a_ompldr-us-west1

for ctx in $(kubectl config get-contexts --kubeconfig=./zpkubeconfig -o name); do
  kubectl --context="${ctx}" apply -f ssl-certs.yaml
  kubectl --context="${ctx}" apply -f secrets.yaml
  kubectl --context="${ctx}" apply -f api-server.yaml
  kubectl --context="${ctx}" apply -f periodic-service.yaml
  kubectl --context="${ctx}" apply -f invoice-service.yaml
  kubectl --context="${ctx}" apply -f web.yaml
done
