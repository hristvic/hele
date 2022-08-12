# Create and mount shared storage between web servers
resource "aws_efs_file_system" "helestore" {
  creation_token = "helestore"


  tags = {
    Name = "Helestore"
  }
}

# Mount EFS Target
resource "aws_efs_mount_target" "mount_target-a" {
  file_system_id  = aws_efs_file_system.helestore.id
  subnet_id       = aws_subnet.private-sn-01.id
  security_groups = [aws_security_group.efs-sg.id]

}

resource "aws_efs_mount_target" "mount_target-b" {
  file_system_id  = aws_efs_file_system.helestore.id
  subnet_id       = aws_subnet.private-sn-02.id
  security_groups = [aws_security_group.efs-sg.id]

}