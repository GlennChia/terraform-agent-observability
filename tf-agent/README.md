# Create a HCP Terraform agent pool, agent token and org default execution mode setting

Step 1: Configure HCP Terraform credentials. Refer to the [tfe_provider authentication docs](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs#authentication) for the various token options and guidance. For example:

```bash
export TFE_TOKEN=example
```

Step 2: Run an apply, review the plan output, and approve the plan accordingly. The apply outputs the agent token that is used by the agent to register itself to the agent pool.

> [!CAUTION]
> In a live environment it is not good practice to output the terraform agent token. The token is output in this repo purely for demo purposes, such that readers can easily pass the token to the Terraform agent container.

```bash
terraform init
terraform apply
```