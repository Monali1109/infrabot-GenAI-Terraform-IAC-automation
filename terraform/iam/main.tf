resource "aws_iam_role" "app_role" {
  name = "ROLE-AWS-APP-PROD-01"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "PROFILE-AWS-APP-PROD-01"
  role = aws_iam_role.app_role.name
}

resource "aws_iam_role" "db_role" {
  name = "ROLE-AWS-DB-PROD-01"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
