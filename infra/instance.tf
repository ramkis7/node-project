resource "aws_instance" "capstone" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.capstone_sg.id]

  user_data = file("${path.module}/bootstrap.sh")

  tags = {
    Name = "capstone-devops"
  }
}
