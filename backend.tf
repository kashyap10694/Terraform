# --- root/backend.tf ---

terraform {
  backend "s3" {
    bucket = "aws-jira-test-10694"
    key    = "remote.tfstate"
    region = "us-west-2"
  }
}