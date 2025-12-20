```
vault policy write backup-policy backup-policy.hcl

vault auth enable aws

vault write auth/aws/role/backup-role \
    auth_type=iam \
    bound_iam_principal_arn=arn:aws:iam::123456789101:role/irsa-role \
    policies=backup-policy \
    ttl=1h

kubectl apply -f backup-cronjob.yaml
kubectl apply -f restore-job.yaml
```
