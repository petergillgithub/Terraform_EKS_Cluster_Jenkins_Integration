
vpc_cidr = "10.1.0.0/16"
comman_tags = {
    "ENV"     = "Devoplment"
    "Company" = "Peter Technologies"
}
environment_name = "Dev"
public_subnet_cidr = ["10.1.0.0/20","10.1.16.0/20"]
private_subnet_cidr = ["10.1.32.0/19","10.1.64.0/18"]
nodegroup_instance_type = "t2.medium"
nodegroup_desired_size = 1
nodegroup_min_size = 1
nodegroup_max_size = 4
