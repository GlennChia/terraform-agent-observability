variable "github_token" {
  description = "A GitHub OAuth / Personal Access Token. When not provided or made available via the GITHUB_TOKEN environment variable, the provider can only access resources available anonymously"
  type        = string
}

variable "number_of_test_workspaces" {
  description = "Number of test workspaces to create"
  type        = number
  default     = 50
}
