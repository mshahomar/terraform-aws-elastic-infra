variable "AWS_REGION" {
  description = "Default AWS Region. Check terraform.tfvars file."
}

variable "CIDR_BLOCK" {
  description = "CIDR for AWS VPC. Check terraform.tfvars file."
}

variable "AZ_A" {
  description = "Availability-Zone A for AWS VPC"
}

variable "AZ_B" {
  description = "Availability-Zone B for AWS VPC"
}

variable "AZ_C" {
  description = "Availability-Zone C for AWS VPC"
}

variable "BASTION_SG" {
  description = "Security Group ID for Bastion Host. Check terraform.tfvars file."
}

variable "WEBSRV_INSTANCE_TYPE" {
  description = "Define EC2 instance type for Web Server. Check terraform.tfvars."
}

variable "KEYPAIR" {
  description = "Path to PEM file/ Public Key. Refer README "
  default = "oms.pub"
}

variable "DOMAIN_NAME" {
  description = "Domain name for this project, used to generate certificate using ACM."
  default = "shah.com"
}
