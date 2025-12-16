data "terraform_remote_state" "tf_agent" {
  backend = "local"

  config = {
    path = "../tf-agent/terraform.tfstate"
  }
}
