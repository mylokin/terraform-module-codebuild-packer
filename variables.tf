variable "name" {}
variable "description" {
  type = "string"
  default = ""
}

variable "timeout" {
  type = "string"
  default = "10"
}
variable "image" {
  type = "string"
  default = "aws/codebuild/ubuntu-base:14.04"
}
variable "compute_type" {
  type = "string"
  default = "BUILD_GENERAL1_SMALL"
}

variable "packer_ami_name" {}
variable "packer_source_ami" {}
variable "packer_source_ami_owner" {}
variable "packer_vpc" {}
variable "packer_subnet" {}
