variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "172.20"
}

variable "vpc_cidr_range" {
  type    = string
  default = ".0.0/16"
}

variable "public_subnet_cidr_range" {
  type = map(map(string))
  default = {
    public_subnet_a = {
      az   = "a"
      cidr = ".0.0/22"
    }
  }
}

variable "private_subnet_cidr_range" {
  type = map(map(string))
  default = {
    private_subnet_a = {
      az   = "a"
      cidr = ".4.0/22"
    },
    private_subnet_c = {
      az   = "c"
      cidr = ".8.0/22"
    },
    private_subnet_d = {
      az   = "d"
      cidr = ".12.0/22"
    }
  }
}

variable "ssh_allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "ec2_instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "key_name" {
  type    = string
  default = ""
}
