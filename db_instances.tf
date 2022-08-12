# Read db user passowrd
data "aws_secretsmanager_secret" "read-pw" {
  name = "db-password-mgr"
  depends_on = [
    aws_secretsmanager_secret.password
  ]
}

data "aws_secretsmanager_secret_version" "rds-pass" {
  secret_id = data.aws_secretsmanager_secret.read-pw.id
}

# Create private subnets for DB in two AZ
resource "aws_subnet" "db-sn-01" {
  vpc_id                  = aws_vpc.hele-vpc.id
  cidr_block              = "10.0.33.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {

    Name = "Database-Subnet-1a"
  }
}

resource "aws_subnet" "db-sn-02" {
  vpc_id                  = aws_vpc.hele-vpc.id
  cidr_block              = "10.0.55.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {

    Name = "Database-Subnet-2b"
  }
}

resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "subnetdb-group"
  subnet_ids = [aws_subnet.db-sn-01.id, aws_subnet.db-sn-02.id]

}

# Deploy DB Instance
resource "aws_db_instance" "db-instance" {
  allocated_storage      = 10
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t2.micro"
  multi_az               = true
  db_name                = "HeleDB"
  username               = "heleuser"
  password               = data.aws_secretsmanager_secret_version.rds-pass.secret_string
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
}