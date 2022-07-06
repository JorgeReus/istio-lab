# Canary release istio setup
Minimal example to implement a canary release.

## Steps
1. Apply the terraform `terraform apply --auto-approve`
2. Get your istio IP (e.g. `ISTIO_IP=$(task get-istio-ip)` from the root)
3. Test with 100% of the traffic to stable: 
    1. `terraform apply --auto-approve`
    2. Run `curl http://$ISTIO_IP/echo/ -w '%{http_code}'`
4. Test with 100% of the traffic to beta: 
    1. `terraform apply -var beta_weight=100 -var stable_weight=0 --auto-approve`
    2. Run `curl http://$ISTIO_IP/echo/ -w '%{http_code}'`
5. Test with 50% of the traffic to beta and 50% to stable: 
    1. `terraform apply -var beta_weight=50 -var stable_weight=50 --auto-approve`
    2. Run `curl http://$ISTIO_IP/echo/ -w '%{http_code}'` several times
