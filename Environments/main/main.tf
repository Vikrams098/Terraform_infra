
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "interview-vpc"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "interview-igw"
  }
}



resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}


resource "aws_subnet" "pri_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}


resource "aws_eip" "my_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}


resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.pub_subnet.id

  tags = {
    Name = "interview-nat"
  }

  depends_on = [
    aws_internet_gateway.my_igw
  ]
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}



resource "aws_route_table_association" "pub_rt_assoc" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}



resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}



resource "aws_route_table_association" "pri_rt_assoc" {
  subnet_id      = aws_subnet.pri_subnet.id
  route_table_id = aws_route_table.pri_rt.id
}


resource "aws_security_group" "pub_sg" {
  name        = "public-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description     = "SSH from public SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.pub_sg.id]

  # HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}



resource "aws_security_group" "pri_sg" {
  name        = "private-sg"
  description = "Private resources security group"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description     = "SSH from public SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.pub_sg.id]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}




resource "aws_instance" "Infra_ec2" {

  ami           = "ami-0ac7b260cf76d8865"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.pub_subnet.id

  vpc_security_group_ids = [
    aws_security_group.pub_sg.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true




  user_data = <<-EOF
    #!/bin/bash
    useradd -m nodeuser
    echo "nodeuser:Password123" | chpasswd
    usermod -aG wheel nodeuser
  EOF

  tags = {
    Name = "machine-test-server"
  }
}