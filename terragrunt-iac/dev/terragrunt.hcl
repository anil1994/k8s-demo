# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# notation.

# Indicate what region to deploy the resources into
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
        project = "k8s-demo-346710"
        region = "europe-west1-b"
}
EOF
}



remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket   = "k8s-demo-dev"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = "k8s-demo-346710"
    location = "eu"
  }
}

# Indicate the input values to use for the variables of the module.
inputs = {



  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
