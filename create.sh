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

sh update.sh

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
