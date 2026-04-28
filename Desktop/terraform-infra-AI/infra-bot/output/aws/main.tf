resource "aws_instance" "est1" {
  ami           = ""
  instance_type = "t3.medium"

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "est1"
    OS   = ""
  }
}
