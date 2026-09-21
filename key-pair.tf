resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-app-key"
  public_key = var.ssh_public_key
}
