provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::303467602807:role/service-network-tester"
  }
  region = var.region
  default_tags {
    tags = {
      "created_by" : "infrahouse/terraform-aws-service-network" # GitHub repository that created a resource
    }

  }
}
