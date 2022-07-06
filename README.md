# Istio lab
This lab is meant to be used as a minimal k8s + istio environment to easily & rapidly test istio functionalities

## Requisites
- [k3d](https://k3d.io/#installation)
- [task](https://taskfile.dev/installation/)
- [terraform 1.0+](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Setup lab
Run `task setup` in the root of the repo, this will:
1. Create a k3d cluster with several nodes.
2. Install istio via helm charts.
3. Configure an Istio gateway and an istio injection-enabled namespace.

You can then go to the [ops dir](./terraform/ops) and start applying individual examples

## Tear up lab
Run `task cleanup` in the root of the repo
