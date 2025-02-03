#!/bin/bash
kubectl apply -f ./jenkins-yaml/serviceAccount.yaml --validate=false
kubectl apply -f ./jenkins-yaml/volume.yaml --validate=false
kubectl apply -f ./jenkins-yaml/deployment.yaml --validate=false
kubectl apply -f ./jenkins-yaml/service.yaml --validate=false