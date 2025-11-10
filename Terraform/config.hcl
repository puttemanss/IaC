# Backend configuration for Terraform state storage
# Usage: terraform init -reconfigure -backend-config=config.hcl

storage_account_name = "<STORAGE_ACCOUNT_NAME>"
container_name       = "<CONTAINER_NAME>"
key                  = "terraform.tfstate"
resource_group_name  = "<RESOURCE_GROUP_NAME>"
subscription_id      = "<SUBSCRIPTION_ID>"
tenant_id            = "<TENANT_ID>"
