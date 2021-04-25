variable "tags" {
  type        = map(string)
  description = "Tags to be set when instance will be provisioned."
}

variable "public_key_material" {
  description = "Public key to add in the instance."
}

variable "instance_type" {
  type        = string
  default     = "t2.large"
  description = "Type of the instance to spawn."
}

variable "ami" {
  type = map(string)

  default = {
    "us-east-1" = "ami-0e925aba673a73a97" #Amazon Container Linux 2 CHI - SL1 ami id
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "keyPath" {
   default = "~/.ssh/id_rsa"
}

