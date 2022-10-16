# Ambient istio demo

This is a short demo to showcase how the istio ambient mesh works, completely based on this [post](https://istio.io/latest/blog/2022/get-started-ambient/), it includes a terratest suite, to test that all the steps of the [post](https://istio.io/latest/blog/2022/get-started-ambient/) work.

## Steps

Run:

- `task cluster:create`
- `task e2e`
- `task infra:destroy`
- `task cluster:destroy`
