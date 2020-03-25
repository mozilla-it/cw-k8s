terraform {
  backend "s3" {
    bucket = "itsre-state-783633885093"
    key    = "us-west-2/newbie/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "deploy" {
  backend = "s3"

  config = {
    bucket = "itsre-state-783633885093"
    key    = "terraform/deploy.tfstate"
    region = "eu-west-1"
  }
}

module "newbie-stage-db" {
  source      = "github.com/mozilla-it/terraform-modules/database"
  type        = "postgres"
  storage_gb  = 20
  name        = "newbiestage"
  identifier  = "newbie-stage"
  username    = "newbie"
  cost_center = "1440"
  environment = "stage"
  instance    = "db.t3.micro"
  project     = "newbie"
  vpc_id      = data.terraform_remote_state.deploy.outputs.vpc_id
  subnets     = [data.terraform_remote_state.deploy.outputs.private_subnets]
}

module "newbie-prod-db" {
  source      = "github.com/mozilla-it/terraform-modules/database"
  type        = "postgres"
  storage_gb  = 20
  name        = "newbie"
  identifier  = "newbie-prod"
  username    = "newbie"
  cost_center = "1440"
  environment = "prod"
  project     = "newbie"
  vpc_id      = data.terraform_remote_state.deploy.outputs.vpc_id
  subnets     = [data.terraform_remote_state.deploy.outputs.private_subnets]
}

output "endpoint" {
  value = module.newbie-prod-db.endpoint
}

output "username" {
  value = module.newbie-prod-db.username
}

output "password" {
  value = module.newbie-prod-db.password
}

output "stage-endpoint" {
  value = module.newbie-stage-db.endpoint
}

output "stage-username" {
  value = module.newbie-stage-db.username
}

output "stage-password" {
  value = module.newbie-stage-db.password
}

