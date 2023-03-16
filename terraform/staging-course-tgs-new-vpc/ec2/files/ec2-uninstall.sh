#!/bin/bash
helm uninstall aws-load-balancer-controller -n kube-system 

helm uninstall nginx-ingress 

eksctl delete addon --cluster tgs-taiwan-k8s --name aws-ebs-csi-driver --preserve
