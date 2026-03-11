
############################################
# VPC + Subnets
############################################
resource "aws_vpc" "tokyovpc" {
  cidr_block           = "10.108.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "tokyo-vpc" }
}

resource "aws_subnet" "tokyo_public_a" {
  vpc_id                  = aws_vpc.tokyovpc.id
  cidr_block              = "10.108.2.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = { Name = "tokyo-public-a" }
}

resource "aws_subnet" "tokyo_public_b" {
  vpc_id                  = aws_vpc.tokyovpc.id
  cidr_block              = "10.108.4.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "tokyo-public-b"
  }
}


resource "aws_subnet" "tokyo_private_a" {
  vpc_id            = aws_vpc.tokyovpc.id
  cidr_block        = "10.108.12.0/24"
  availability_zone = "ap-northeast-1a"
  tags = { Name = "tokyo-private-a" }
}

resource "aws_subnet" "tokyo_private_b" {
  vpc_id            = aws_vpc.tokyovpc.id
  cidr_block        = "10.108.22.0/24"
  availability_zone = "ap-northeast-1c"
  tags = { Name = "tokyo-private-b" }
}


############################################
# Internet Gateway + Routing
############################################
resource "aws_internet_gateway" "tokyo" {
  vpc_id = aws_vpc.tokyovpc.id
  tags = { Name = "tokyo-igw" }
}

# -----------------------------
# PUBLIC ROUTE TABLE
# -----------------------------
resource "aws_route_table" "tokyo_public_rt" {
  vpc_id = aws_vpc.tokyovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tokyo.id
  }

  tags = { Name = "tokyo-public-rt" }
}

resource "aws_route_table_association" "tokyo_public_assoc" {
  subnet_id      = aws_subnet.tokyo_public_a.id
  route_table_id = aws_route_table.tokyo_public_rt.id
}

# -----------------------------
# PRIVATE ROUTE TABLE
# -----------------------------
resource "aws_route_table" "tokyo_private_rt" {
  vpc_id = aws_vpc.tokyovpc.id
  tags = { Name = "tokyo-private-rt" }
}

resource "aws_route_table_association" "tokyo_private_assoc_a" {
  subnet_id      = aws_subnet.tokyo_private_a.id
  route_table_id = aws_route_table.tokyo_private_rt.id
}

resource "aws_route_table_association" "tokyo_private_assoc_b" {
  subnet_id      = aws_subnet.tokyo_private_b.id
  route_table_id = aws_route_table.tokyo_private_rt.id
}

resource "aws_route" "tokyo_private_default_route" {
  route_table_id         = aws_route_table.tokyo_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tokyo_nat.id
}




# ############################################
# # security group tokyo vault opents only to approved clinics
# ############################################


resource "aws_security_group" "medical_rds_sg01" {
  name        = "medical-rds-sg01"
  description = "Tokyo RDS security group"
  vpc_id      = aws_vpc.tokyovpc.id

  # RDS needs outbound access for DNS, updates, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  description = "Allow Sao Paulo app tier"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = ["10.208.0.0/16"]  # Sao Paulo VPC CIDR
}


  tags = {
    Name = "medical-rds-sg01"
  }
}

resource "aws_security_group_rule" "shinjuku_rds_ingress_from_liberdade01" {
  type              = "ingress"
  security_group_id = aws_security_group.medical_rds_sg01.id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  

  cidr_blocks = ["10.208.0.0/16"] # Sao Paulo VPC CIDR
}

resource "aws_vpc_security_group_ingress_rule" "tokyo_app_to_rds" {
  security_group_id            = aws_security_group.medical_rds_sg01.id
  referenced_security_group_id = aws_security_group.tokyo_app_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}







############################################
# RDS (Authoritative Database)
############################################
resource "aws_db_subnet_group" "tokyosub" {
  name       = "tokyo-db-subnet-group"
  subnet_ids = [aws_subnet.tokyo_private_a.id, aws_subnet.tokyo_private_b.id]
}

resource "aws_db_instance" "tokyo_rds" {
  identifier              = "tokyo-medical-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = "Tunerz1100!"
  db_subnet_group_name    = aws_db_subnet_group.tokyosub.name
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false

  vpc_security_group_ids = [aws_security_group.medical_rds_sg01.id]
}




#################
# IAM ROLE
#################
resource "aws_iam_role" "tokyo_ec2_role" {
  name = "tokyo-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "tokyo_ec2_basic" {
  role       = aws_iam_role.tokyo_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "tokyo_ec2_instance_profile" {
  name = "tokyo-ec2-instance-profile"
  role = aws_iam_role.tokyo_ec2_role.name

}


