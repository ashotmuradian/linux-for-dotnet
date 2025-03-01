#!/bin/bash
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
kubectl run postgresql-client-$(date +%s) --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:17.4.0 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host postgresql -U postgres -d postgres -p 5432
