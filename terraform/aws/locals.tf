locals {
  project     = "demo"
  environment = "dev"
  name_prefix = "${local.project}-${local.environment}"
}
