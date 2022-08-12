# Create random password for user
resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

# Create Secret to store the password
resource "aws_secretsmanager_secret" "password" {
  name = "db-password-mgr"
}

# Use secret to parse password in secret
resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result
}