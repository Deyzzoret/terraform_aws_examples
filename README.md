# terraform_aws_examples
Terraform aws examples

# Create image containing Terraform and AWS cli

```sh

docker build -t local-terraform:0.0.1 . 

docker run -it --rm -v J:/jcca/git/terraform_aws_examples/:/wk -w /wk --entrypoint /bin/sh  local-terraform:0.0.1 

```

# Download provider 

```
terraform init
``` 

# Deploy insfractructure provider 

```
terraform apply
``` 

# Show insfractructure's preview 

```
terraform plan
``` 

# Destroy insfractructure

```
terraform destroy
```