module "secrets" {
  source = "../../modules/secrets"
  ns_username_secret = var.ns_username_secret
  ns_password_secret = var.ns_password_secret

}

# dev and prod own their lbvservers; read the names from their state
data "terraform_remote_state" "dev" {
  backend = "gcs"
  config = {
    bucket      = "adc-pm-demo-tfstate"
    prefix      = "netscaler/dev"
    credentials = "~/terraform-sa.json"
  }
}

data "terraform_remote_state" "prod" {
  backend = "gcs"
  config = {
    bucket      = "adc-pm-demo-tfstate"
    prefix      = "netscaler/prod"
    credentials = "~/terraform-sa.json"
  }
}

module "cs" {
  source = "../../modules/cs"

  csvserver_name = var.csvserver_name
  netscaler_private_vip = var.netscaler_private_vip
  # / and any other unmatched path go to dev
  default_lbvserver_name = data.terraform_remote_state.dev.outputs.lbvserver_name
  routes = {
    dev = {
      path           = "/dev"
      lbvserver_name = data.terraform_remote_state.dev.outputs.lbvserver_name
      priority       = 100
    }
    prod = {
      path           = "/prod"
      lbvserver_name = data.terraform_remote_state.prod.outputs.lbvserver_name
      priority       = 110
    }
  }
}
