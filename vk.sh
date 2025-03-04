#!/bin/bash
export VALKEY_PASSWORD=$(kubectl get secret --namespace default valkey -o jsonpath="{.data.valkey-password}" | base64 -d)
kubectl run valkey-client-$(date +%s) --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/valkey:8.0.2 \
	--env "REDISCLI_AUTH=$VALKEY_PASSWORD" \
	--command -- bash -c "sleep 1 && echo connecting && valkey-cli -h valkey-primary"
 
