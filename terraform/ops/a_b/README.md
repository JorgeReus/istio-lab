# A/B testing istio setup
Minimal example to implement A/B testing.

## Steps
1. Apply the terraform `terraform apply --auto-approve`
2. Get your istio IP (e.g. `ISTIO_IP=$(task get-istio-ip)` from the root)
3. Run `curl http://$ISTIO_IP/echo/ -w '%{http_code}'` to hit the stable version of the service
3. Run `curl http://$ISTIO_IP/echo/ -H 'version: beta' -w '%{http_code}'` to hit the beta version of the service
