# Digital Ocean Kubernetes

Deployment guide for FQAuth on Digital Ocean Kubernetes

## Pre reqs

1. A Kubernetes cluster
2. A Redis instance, accessible from the cluster
3. A Postgres instance, accessible from the cluster

## Install

1. Gather URLs for Redis and Postgres
2. `kubectl apply -Rf Deploy/Kubernetes/
3. Set up ingress resources in your cluster.
