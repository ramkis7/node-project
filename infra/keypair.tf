variable "pub_key_path" {
  default = "~/.ssh/capstone-key.pub"
}

resource "aws_key_pair" "deployer" {
  key_name   = "capstone-key"
  public_key = file(var.pub_key_path)
}
