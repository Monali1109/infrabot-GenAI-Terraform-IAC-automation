resource "aws_instance" "webservrtst1" {
  ami           = ""
  instance_type = "t3.medium"

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "webservrtst1"
    OS   = ""
  }
}
