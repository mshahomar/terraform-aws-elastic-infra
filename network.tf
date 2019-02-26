resource "aws_vpc" "vpc" {
    cidr_block = "${var.CIDR_BLOCK}"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
      Name = "${local.project_name}-vpc"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${local.project_name}-igw"
    }  
}


# Private Subnets - Reserved for DB, App Server
resource "aws_subnet" "private-1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)}"
    map_public_ip_on_launch = "false"
    availability_zone = "${var.AZ_A}"

    tags {
        Name = "${local.project_name}-pvt-1"
    }
}

resource "aws_subnet" "private-2" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2)}"
    map_public_ip_on_launch = "false"
    availability_zone = "${var.AZ_B}"

    tags {
        Name = "${local.project_name}-pvt-2"
    }
}

resource "aws_subnet" "private-3" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 3)}"
    map_public_ip_on_launch = "false"
    availability_zone = "${var.AZ_C}"

    tags {
        Name = "${local.project_name}-pvt-3"
    }
}


# Public Subnets - Normally ELB
resource "aws_subnet" "public-1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 11)}"
    map_public_ip_on_launch = "true"
    availability_zone = "${var.AZ_A}"

    tags {
        Name = "${local.project_name}-pub-1"
    }
}

resource "aws_subnet" "public-2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 12)}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AZ_B}"

  tags {
      Name = "${local.project_name}-pub-2"
  }
}

resource "aws_subnet" "public-3" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 13)}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AZ_C}"

  tags {
      Name = "${local.project_name}-pub-3"
  }
}


# Route Table - Public
resource "aws_route_table" "rtb-public" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }
    tags {
        Name = "${local.project_name}-rtb-public"
    }
}

resource "aws_route_table_association" "rta-subnet-public-1a" {
    route_table_id = "${aws_route_table.rtb-public.id}"
    subnet_id = "${aws_subnet.public-1.id}"  
}

resource "aws_route_table_association" "rta-subnet-public-1b" {
  route_table_id = "${aws_route_table.rtb-public.id}"
  subnet_id = "${aws_subnet.public-2.id}"
}

resource "aws_route_table_association" "rta-subnet-public-1c" {
  route_table_id = "${aws_route_table.rtb-public.id}"
  subnet_id = "${aws_subnet.public-3.id}"
}


# NAT GW Settings: EIP, NAT-GW, Route Table
resource "aws_eip" "eip" {
  vpc = true
  tags {
    Name = "${local.project_name}-NATGW-EIP"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.eip}"
  subnet_id = "${aws_subnet.public-1.id}"
  depends_on = ["aws_internet_gateway.igw"]
  tags {
    Name = "${local.project_name}-NATGW"
  }
}

# Route table - Private
resource "aws_route_table" "rtb-private" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }
  tags {
    Name = "${local.project_name}-rtb-private"
  }
}

resource "aws_route_table_association" "rta-subnet-private-1a" {
  route_table_id = "${aws_route_table.rtb-private.id}"
  subnet_id = "${aws_subnet.private-1.id}"
}

resource "aws_route_table_association" "rta-subnet-private-1b" {
  route_table_id = "${aws_route_table.rtb-private.id}"
  subnet_id = "${aws_subnet.private-2.id}"
}

resource "aws_route_table_association" "rta-subnet-private-1c" {
  route_table_id = "${aws_route_table.rtb-private.id}"
  subnet_id = "${aws_subnet.private-3.id}"
}
