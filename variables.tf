variable "ami" {
  description = "Value of the ami"
  type        = string
  default = "ami-0b7282dd7deb48e78"
}

variable "region" {
  description = "Value of the cluster region"
  type        = string
  default = "eu-west-3"
}

variable "vpc_security_group_id" {
  description = "Value of the AWS secutiry group id"
  type        = string
  default = "sg-0b382662fbf5c3b45" # Change by your VPC id
}

variable "key_name" {
  description = "Value of the AWS key name"
  type        = string
  default = "tp_devops" # Change by key pair name
}

variable "private_key_path" {
  description = "Value of the AWS private key path"
  type        = string
  default = "./private_key.pem" # Change by private key path saved on this root folder 
}