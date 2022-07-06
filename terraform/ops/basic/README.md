# Basic traffic management istio setup
Minimal example of:
- [Virtual Services](https://istio.io/latest/docs/concepts/traffic-management/#virtual-services)
- [Routing](https://istio.io/latest/docs/concepts/traffic-management/#routing-rules)
- [Destination Rules](https://istio.io/latest/docs/concepts/traffic-management/#destination-rules)
- [Gateways](https://istio.io/latest/docs/concepts/traffic-management/#gateways)
- [Timeouts](https://istio.io/latest/docs/concepts/traffic-management/#gateways)
- [Retries](https://istio.io/latest/docs/concepts/traffic-management/#gateways)
- [Circuit Breakers](https://istio.io/latest/docs/concepts/traffic-management/#gateways)
- [Fault inject without istio](https://istio.io/latest/docs/concepts/traffic-management/#fault-injection)

## Steps
1. Apply the terraform `terraform apply --auto-approve`
2. Get your istio IP (e.g. `ISTIO_IP=$(task get-istio-ip)` from the root)
3. Run `curl http://$ISTIO_IP/app/ -w '%{http_code}'` to get a `200 OK`
4. Test random 5xx errors: 
    1. Modify the [config](./files/mock_config.yaml) by uncommenting the control section and the crazy mode
    ```
    ...
    control:
      crazy: true
    ...
    ```
    2. Run `curl http://$ISTIO_IP/app/  -w '%{http_code}\nTime: %{time_total}'` several times and see the timings, retry config doing it's work 

4. Test timeouts: 
    1. Modify the [config](./files/mock_config.yaml) by uncommenting the control section and the delay
    ```
    ...
    control:
      delay: "5s"
    ...
    ```
    2. Run `curl http://$ISTIO_IP/app/  -w '%{http_code}\nTime: %{time_total}'` several times and see the timings, app is taking 5 seconds to respond
    3. Change the `retry_config.perTryTimeout` to 1
    4. Run `curl http://$ISTIO_IP/app/  -w '%{http_code}\nTime: %{time_total}'` several times and see the timings, istio now timeouts due to upstream

5. Test circuit breakers 
    1. Modify the [config](./files/mock_config.yaml) by changing the response code to 500
    ```
    ...
    ...
    response:
    statusCode: 500
    ...
    ```
    2. Run `curl http://$ISTIO_IP/app/  -w '%{http_code}` several times util the response code is `503 no healthy upstream`, that is the circuit breaker tripping
