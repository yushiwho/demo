variable "region" {
  type        = string
  default     = "us-west-1"
  description = "Provider region"
}

variable "profile" {
  type        = string
  default     = "default"
  description = "AWS CLI profile name"
}

variable "domain_name" {
  type        = string
  description = "demo app domain name"
}

variable "zone_name" {
  type        = string
  description = "aws hosted zone name"
}

variable "alb_address" {
  type        = string
  default     = "<change-me>"
  description = "front app alb address"
}
