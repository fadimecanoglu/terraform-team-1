data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    # change backet name to  terraform-tfstate-<YOUR-NAME> 
    bucket = "terraform-tfstate-rus" # !!!
    
    key    = "project-team-1/dev/vpc"
    region = "us-east-1"
  }
}

output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

