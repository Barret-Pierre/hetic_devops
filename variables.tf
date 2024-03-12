variable "vpc_security_group_id" {
  description = "Value of the secutiry group id"
  type        = string
  default = "sg-0b382662fbf5c3b45"
}

variable "key_name" {
  description = "Value of the key_name"
  type        = string
  default = "tp_devops"
}

variable "private_key_path_file" {
  description = "Value of the private key path file"
  type        = string
  default = "./tp_devops.pem"
}

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