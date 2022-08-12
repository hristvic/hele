# Create Security Groups
resource "aws_security_group" "web-sg" {
  name        = "web-SG"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.hele-vpc.id

  ingress {
    from_port   = "80"
    to_port     = "80"
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

resource "aws_security_group" "instance-sg" {
  name        = "Server-SG"
  description = "Allow Server Access"
  vpc_id      = aws_vpc.hele-vpc.id

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "db-sg" {
  name        = "Database-SG"
  description = "Allow DB Access"
  vpc_id      = aws_vpc.hele-vpc.id

  ingress {
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.instance-sg.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs-sg" {
  name        = "EFS-SG"
  description = "Allow Server Access"
  vpc_id      = aws_vpc.hele-vpc.id

  ingress {
    from_port       = "2049"
    to_port         = "2049"
    protocol        = "tcp"
    security_groups = [aws_security_group.instance-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}