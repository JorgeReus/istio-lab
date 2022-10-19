variable "k8s-svc-host" {
  default     = "istio-cilium-control-plane"
  description = "The master node hostname available from the docker network"
}

variable "metallb_addr_range" {
  default     = "172.21.255.200-172.21.255.250"
  description = "The address range of the metallb network loadbalancer, its based on the kind network CIDR"
}

variable "metallb_chart_version" {
  default     = "0.13.5"
  description = "The version of the metallb chart to use"
}
