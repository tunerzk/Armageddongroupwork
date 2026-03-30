
provider "aws" {
  region = "sa-east-1"
}



provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "saopaulo"
  region = "sa-east-1"
}







resource "aws_vpc" "liberdade_vpc01" {
  cidr_block = "10.208.0.0/16"
  tags       = { Name = "liberdade-vpc01" }
}

########################################
# subnets, route tables, and TGW attachment for SAO PAULO
########################################
resource "aws_subnet" "liberdade_private_subnet01" {
  vpc_id            = aws_vpc.liberdade_vpc01.id
  cidr_block        = "10.208.12.0/24"
  availability_zone = "sa-east-1a"
  tags              = { Name = "liberdade-private-a" }
}

resource "aws_subnet" "liberdade_public_subnet01" {
  
  vpc_id                  = aws_vpc.liberdade_vpc01.id
  cidr_block              = "10.208.1.0/24"
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "liberdade-public-subnet01"
  }
}

resource "aws_subnet" "liberdade_public_subnet02" {
  
  vpc_id                  = aws_vpc.liberdade_vpc01.id
  cidr_block              = "10.208.2.0/24"
  availability_zone       = "sa-east-1b"
  map_public_ip_on_launch = true


  


  tags = {
    Name = "liberdade-public-subnet02"
  }
}

resource "aws_route_table" "liberdade_private_rt01" {
  vpc_id = aws_vpc.liberdade_vpc01.id
  tags   = { Name = "liberdade-private-rt01" }
}

resource "aws_route_table_association" "liberdade_private_assoc01" {
  subnet_id      = aws_subnet.liberdade_private_subnet01.id
  route_table_id = aws_route_table.liberdade_private_rt01.id
}

resource "aws_route_table_association" "liberdade_public_assoc01" {
  subnet_id      = aws_subnet.liberdade_public_subnet01.id
  route_table_id = aws_route_table.liberdade_public_rt.id
}

resource "aws_route_table_association" "liberdade_public_assoc02" {
  subnet_id      = aws_subnet.liberdade_public_subnet02.id
  route_table_id = aws_route_table.liberdade_public_rt.id
}


#######################
# AWS IAM Role and Instance Profile for SAO PAULO EC2s
###########################
resource "aws_iam_role" "saopaulo_ec2_role" {
  name = "saopaulo-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "saopaulo_ec2_basic" {
  role       = aws_iam_role.saopaulo_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "saopaulo_ec2_profile" {
  name = "saopaulo-ec2-profile"
  role = aws_iam_role.saopaulo_ec2_role.name
}

resource "aws_iam_role_policy" "saopaulo_passrole" {
  name = "saopaulo-passrole"
  role = aws_iam_role.saopaulo_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}


############################
# IGW for SAO PAULO
############################
resource "aws_internet_gateway" "liberdade_igw01" {
  vpc_id = aws_vpc.liberdade_vpc01.id
  tags   = { Name = "liberdade-igw01" }
}