#Create IAM policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality 
data "aws_iam_policy" "SSM" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the Role
resource "aws_iam_instance_profile" "ec2-profile" {
  name = "web-server"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role" "ec2-role" {
  name               = "web-server-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# Attach Role to Policy
resource "aws_iam_role_policy_attachment" "SSM-instance-mgmt" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = data.aws_iam_policy.SSM.arn
}