# Infrastructure folder for the ambient demo

This folder contains terraform files that setup istio in ambient mode and related components

## Plan/Apply

Doing a regular terraform workflow will be needed:

> :warning: **This will deploy resources in a k8s cluster**: Be very careful on which is your current context!

1. `terraform init`
2. `terraform plan -out makeitso.tfplan`
3. `terraform appy makeitso`

## Testing

Under the [tests](./tests) folder to a `go test -v`
