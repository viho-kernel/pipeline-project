resource "aws_instance" "project-server" {
    ami = "ami-02d26659fd82cf299"
    instance_type = "t3.medium"
    key_name = "Project_Pair"
    //security_groups = [aws_security_group.project-sg.name]
    subnet_id = aws_subnet.project-subnet-01.id
    vpc_security_group_ids = [aws_security_group.project-sg.id]
    for_each = toset(["Jenkins-Master", "Jenkins-Slave", "Ansible"])
    tags = {
        Name = "${each.key}"
    }

    root_block_device {
        volume_size = 30
        volume_type = "gp3"
    }
  
}

resource "aws_security_group" "project-sg" {
    name        = "project-security-group"
    description = "Security group for project server"
    vpc_id      = aws_vpc.project-vpc.id

    ingress {
        description = "Allow SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Jenkins Port"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_vpc" "project-vpc" {
  cidr_block = "10.1.0.0/16"
    tags = {
        Name = "ProjectVPC"
        Environment = "Development"
    }  

}

resource "aws_subnet" "project-subnet-01" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
    tags = {
        Name = "ProjectSubnet-01"
        Environment = "Development"
    }
}

resource "aws_subnet" "project-subnet-02" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
    tags = {
        Name = "ProjectSubnet-02"
        Environment = "Development"
    }
}

resource "aws_internet_gateway" "project-igw" {
  vpc_id = aws_vpc.project-vpc.id
    tags = {
        Name = "ProjectIGW"
        Environment = "Development"
    }   
  
}

resource "aws_route_table" "project-route-table" {
  vpc_id = aws_vpc.project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-igw.id
  }
    tags = {
        Name = "ProjectRouteTable"
        Environment = "Development"
    }
  
}

resource "aws_route_table_association" "project-route-table-assoc-01" {
  subnet_id      = aws_subnet.project-subnet-01.id
  route_table_id = aws_route_table.project-route-table.id
}

resource "aws_route_table_association" "project-route-table-assoc-02" {
  subnet_id      = aws_subnet.project-subnet-02.id
  route_table_id = aws_route_table.project-route-table.id
}

  module "sgs" {
    source = "../sg_eks"
    vpc_id     =     aws_vpc.project-vpc.id
 }

  module "eks" {
       source = "../eks"
       vpc_id     =     aws_vpc.project-vpc.id
       subnet_ids = [aws_subnet.project-subnet-01.id,aws_subnet.project-subnet-02.id]
       sg_ids = module.sgs.security_group_public
 }