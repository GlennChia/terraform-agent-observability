output "docker_agent_pool_commands" {
  value       = <<EOT
export TFC_AGENT_TOKEN=${nonsensitive(tfe_agent_token.this.token)}
export TFC_AGENT_NAME=${tfe_agent_pool.this.name}
docker compose up
EOT
  description = "Commands to launch a HCP TF Agent, prometheus, grafana, and jaeger"
}

output "tf_organization_name" {
  value       = var.tf_organization_name
  description = "The name of the Terraform Organization to create the agent pool in"
}