#!/bin/bash
# install aws-node-termination-handler
# https://ec2spotworkshops.com/using_ec2_spot_instances_with_eks/070_selfmanagednodegroupswithspot/deployhandler.html
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-node-termination-handler \
             --namespace kube-system \
             eks/aws-node-termination-handler
  