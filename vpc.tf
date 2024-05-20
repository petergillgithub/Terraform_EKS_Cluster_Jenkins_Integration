resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(var.comman_tags, {
    "Name"                                                                      = "${var.project_name}-${var.environment_name}-vpc",
    "kubernetes.io/cluster/${var.project_name}-${var.environment_name}-cluster" = "owned"
    }
  )
}

//Public Subnets
resource "aws_subnet" "publicsubnets" {
  count = length(var.public_subnet_cidr)

  vpc_id = aws_vpc.main.id

  cidr_block = element(var.public_subnet_cidr, count.index)

  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(var.comman_tags, {
    "Name"                                                                      = "${var.project_name}-${var.environment_name}-vpc-public-subnets-${count.index + 1}",
    "kubernetes.io/cluster/${var.project_name}-${var.environment_name}-cluster" = "owned"
    "kubernetes.io/role/elb"                                                    = "1"
    }
  )

}

//Private Subnets
resource "aws_subnet" "privatesubnets" {
  count = length(var.private_subnet_cidr)

  vpc_id = aws_vpc.main.id

  cidr_block = element(var.private_subnet_cidr, count.index)

  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]

  tags = merge(var.comman_tags, {
    "Name"                                                                      = "${var.project_name}-${var.environment_name}-vpc-private-subnets-${count.index + 1}",
    "kubernetes.io/cluster/${var.project_name}-${var.environment_name}-cluster" = "owned"
    "kubernetes.io/role/internal-elb"                                           = "1"
    }
  )

}

//InternetGateway for Public Subnet

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id


  tags = merge(var.comman_tags, {
    "Name" = "${var.project_name}-${var.environment_name}-vpc-igw"
  })

}

//ROUTE TABLE

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.comman_tags, {
    "Name" = "${var.project_name}-${var.environment_name}-vpc-publicrt"
  })

}
//Public Route table Association

resource "aws_route_table_association" "publicrouteassociation" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.publicsubnets[*].id, count.index)
  route_table_id = aws_route_table.publicrt.id
}

//Elastic IP

resource "aws_eip" "eips" {
  count  = length(var.public_subnet_cidr)
  domain = "vpc"

  tags = merge(var.comman_tags, {
    "Name" = "${var.project_name}-${var.environment_name}-vpc-eips-${count.index + 1}"
  })
}

//NAT GATEWAY 

resource "aws_nat_gateway" "natgateway" {
  count         = length(var.public_subnet_cidr)
  allocation_id = element(aws_eip.eips[*].id, count.index)              #aws_eip.eips[count.index].id
  subnet_id     = element(aws_subnet.privatesubnets[*].id, count.index) #aws_subnet.privatesubnets[count.index].id

  tags = merge(var.comman_tags, {
    "Name" = "${var.project_name}-${var.environment_name}-vpc-natgetwat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

//Private Route Table
resource "aws_route_table" "privatert" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = element(aws_nat_gateway.natgateway[*].id, count.index) #aws_nat_gateway.natgateway[count.index].id
  }
  tags = merge(var.comman_tags, {
    "Name" = "${var.project_name}-${var.environment_name}-vpc-privatert-${count.index + 1}"
  })

}

//Private subnet association

resource "aws_route_table_association" "privaterouteassociation" {
  count             = length(var.private_subnet_cidr)
  route_table_id    = element(aws_route_table.privatert[*].id,count.index) #awsaws_route_table.privatert[count.index].id 

  subnet_id         = element(aws_subnet.privatesubnets[*].id,count.index) #aws_subnet.privatesubnets[count.index].id 
}