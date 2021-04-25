variable "name" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "terraform" {
  type = string
}

variable "public_key_material" {
  description = "Public key to add in the instance."
}
