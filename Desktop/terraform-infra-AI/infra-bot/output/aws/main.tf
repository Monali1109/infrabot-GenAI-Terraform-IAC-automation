resource "aws_instance" "sevr1" {
  ami           = ""
  instance_type = "t3.medium"

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "sevr1"
    OS   = ""
  }
}

# test-pr-20260428_153841
