#!/bin/sh

# Contexts:
#  gke_ompldr_us-east4-a_ompldr-us-east4
#  gke_ompldr_us-west1-a_ompldr-us-west1

gcloud container clusters get-credentials ompldr-us-east4 --zone=us-east4-a
gcloud container clusters get-credentials ompldr-us-west1 --zone=us-west1-a

kubectl config use-context gke_ompldr_us-east4-a_ompldr-us-east4
kubectl config view --minify --flatten > mciuseast

kubectl config use-context gke_ompldr_us-west1-a_ompldr-us-west1
kubectl config view --minify --flatten > mcieuwest

KUBECONFIG=mciuseast:mcieuwest kubectl config view --flatten > zpkubeconfig

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
done

kubemci create api-server --ingress=api-server-ingress.yaml --gcp-project=ompldr --kubeconfig=zpkubeconfig --force

gcloud compute health-checks update http mci1-hc-30061--api-server \
  --check-interval=5s \
  --timeout=5s \
  --healthy-threshold=2 \
  --unhealthy-threshold=2 \
  --port=30061 \
  --request-path=/ping

kubemci create web --ingress=web-ingress.yaml --gcp-project=ompldr --kubeconfig=zpkubeconfig --force

gcloud compute health-checks update http mci1-hc-30062--web \
  --check-interval=5s \
  --timeout=5s \
  --healthy-threshold=2 \
  --unhealthy-threshold=2 \
  --port=30062 \
  --request-path=/ping
