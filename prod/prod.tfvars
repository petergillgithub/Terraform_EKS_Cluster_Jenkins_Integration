environment_name = "Production"
vpc_cidr = "10.2.0.0/16"
comman_tags = {
    "ENV"     = "Production"
    "Company" = "Peter Technologies"
}
public_subnet_cidr = ["10.2.0.0/20","10.2.16.0/20"]
private_subnet_cidr = ["10.2.32.0/19","10.2.64.0/18"]