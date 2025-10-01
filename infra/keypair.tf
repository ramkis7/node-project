variable "pub_key_path" {
  default = "C:/Users/ramki/OneDrive/Desktop/AWS_SESSION/rams23jul2025.pub"
}

resource "aws_key_pair" "deployer" {
  key_name   = "capstone-key"
  public_key = file(var.pub_key_path)
}
