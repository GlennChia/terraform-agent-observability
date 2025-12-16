resource "tfe_project" "agent_test" {
  organization = local.tf_organization_name
  name         = "tf-agent-test"
}

resource "tfe_workspace" "basic" {
  depends_on = [github_repository_file.main_tf]

  for_each = { for i in range(1, var.number_of_test_workspaces + 1) : tostring(i) => i }

  name           = "example-${each.key}"
  organization   = local.tf_organization_name
  queue_all_runs = true
  project_id     = tfe_project.agent_test.id
  force_delete   = true
  auto_apply     = true

  vcs_repo {
    branch         = local.github_branch
    identifier     = github_repository.this.full_name
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}
