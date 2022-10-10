variable "istio_version" {
  default     = "0.0.0-ambient.191fe680b52c1754ee72a06b3e0d3f9d116f2e82"
  description = "The version of the istio release to use, it should support ambient mode"
}

variable "metallb_addr_range" {
  default     = "172.21.255.200-172.21.255.250"
  description = "The address range of the metallb network loadbalancer, its based on the kind network CIDR"
}

variable "metallb_chart_version" {
  default     = "0.13.5"
  description = "The version of the metallb chart to use"
}
