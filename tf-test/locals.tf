locals {
  github_branch        = "main"
  tf_organization_name = data.terraform_remote_state.tf_agent.outputs.tf_organization_name
}