# Create infra for MM project

## Prerequisite
### Create service principal for terraform:

`az ad sp create-for-rbac -n sp-mm-github-terraform --role contributor --scopes "/subscriptions/023a4329-7db4-42dd-85cd-84e08a2075a9" --sdk-auth`

### Add API permissions:
Add `Application.ReadWrite.OwnedBy` with type: `Application` in App registration for your created service principal.
https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application

### Recevie state storage key. Run when state storage account created.

`az storage account keys list --resource-group rg-mm-tfstate-prod --account-name stmmtfstateprod --query '[0].value' -o tsv`

### Set bellow secrets in GitHub actions:

`ARM_ACCESS_KEY`
`ARM_CLIENT_ID`
`ARM_CLIENT_SECRET`
`ARM_SUBSCRIPTION_ID`
`ARM_TENANT_ID`

# Manual env setup

1) Run terraform from state folder to create backend storage for
terraform state file

`cd state`

`terraform init`

`terraform apply --auto-approve`

2) Create infra resource group for general resources for non production and production environments

`cd infra`

`terraform init -backend-config=../backend/config.infra_nonprod.tfbackend`

  `../backend/config.infra_nonprod.tfbackend` - static file with hardcoded values

`terraform apply --auto-approve` 

3) Create objects for remaining application

from mm-infra run

`terraform init -backend-config=./backend/config.general_test.tfbackend`

  `../backend/config.general_test.tfbackend` - static file with hardcoded values

`terraform apply --auto-approve` 

Option when variables are provided via file:
`terraform apply -var-file=local.tfvar`

---
Create storage account for state file.
Two storage accounts are required
One for non-prod env state files, other for prod env state file.
