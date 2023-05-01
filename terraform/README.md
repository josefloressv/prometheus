# Bastion Host

# Deploy the infrastructure
```bash
terraform init
terraform apply -auto-approve
```

# Connect to the instance
```bash
chmod 400 tf-key-pair
ssh -i tf-key-pair.pem ec2-user@IPADDR
```
