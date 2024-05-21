#MAIN VPC DETAILS


//MAIN VPC CIDR VARS !
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC Primary CIDR"
}

//PROJECT NAME

variable "project_name" {
  type    = string
  default = "JOEL INNFOTECH"
}

//ENVIRONMENT NAME
variable "environment_name" {
  type    = string
  default = "DEV"

}

//MAIN VPC ENABLE DNS SUPPORT

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "ENABLE DNS SUPPORT"

}

//MAIN VPC ENABLE DNS HOSTNAME 
variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "ENABLE DNS HOSTNAME"
}

//TAGS INFO
variable "comman_tags" {
  type = map(string)
  default = {
    "ENV"     = "Devoplment"
    "Company" = "Peter Technologies"

  }

}
////////////////////////////////////////////////////////////////////////
#SUBNET DETAILS

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.0.0/21", "10.0.8.0/21", "10.0.16.0/20"]

}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.32.0/19", "10.0.64.0/18", "10.0.128.0/17"]

}


//eks_worker_nodegroup_policy
variable "eks_worker_nodegroup_policy" {
  type = set(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]


}


variable "nodegroup_instance_type" {
  type = string
  default = "t2.medium"
}

variable "nodegroup_desired_size" {
  type = number
  default = 1
}

variable "nodegroup_min_size" {
  type = number
  default =  1
}

variable "nodegroup_max_size" {
  type = number
  default = 4
}

