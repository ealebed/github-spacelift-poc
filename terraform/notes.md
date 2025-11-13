```bash
cd terraform/envs/dev

terraform init -reconfigure -backend-config=dev.tfbackend

terraform plan
```

or

```bash
cd terraform/envs/prod

terraform init -reconfigure backend-config=prod.tfbackend

terraform plan
```
