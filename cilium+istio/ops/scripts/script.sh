#!/bin/bash

set -e

pub_key="$(docker exec istio-cilium-control-plane cat /etc/kubernetes/pki/sa.pub)"

jq -n --arg pub_key "$pub_key"  '{"pub_key":$pub_key}'
