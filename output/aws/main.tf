resource "aws_instance" "test_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  tags = { Name = "test_server" }
}
