resource "tfe_agent_pool" "this" {
  name                = "demo-agent-pool"
  organization        = var.tf_organization_name
  organization_scoped = true
}

resource "tfe_agent_token" "this" {
  agent_pool_id = tfe_agent_pool.this.id
  description   = "demo token"
}

resource "tfe_organization_default_settings" "agent_pool" {
  organization           = var.tf_organization_name
  default_execution_mode = "agent"
  default_agent_pool_id  = tfe_agent_pool.this.id
}