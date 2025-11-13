Export ENV variables:
```bash
export TF_VAR_spacelift_key_id=....
export TF_VAR_spacelift_key_secret=...
```

(OPTIONAL) Export endpoint ENV variable:
```bash
export TF_VAR_api_key_endpoint="https://ealebed.app.spacelift.io"
```

```bash
cd spacelift

terraform init -reconfigure -backend-config=local.tfbackend

terraform plan
```
