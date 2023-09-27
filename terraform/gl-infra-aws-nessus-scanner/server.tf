## Nessus VM Scanner Server Provision ##

# Find the latest Amazon Linux 2 AMI
data "aws_ami" "nessus-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Template out cloud-init file
data "cloudinit_config" "init" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init.yaml", {
      key : var.tenable_linking_key,
      name : var.scanner_name,
      nessus_ver : var.nessus_version
    })
  }
}

# Create the instance
resource "aws_instance" "nessus-scanner" {
  ami                         = data.aws_ami.nessus-image.id
  vpc_security_group_ids      = [aws_security_group.nessus-security-group.id]
  iam_instance_profile        = aws_iam_instance_profile.nessus-server-profile.name
  subnet_id                   = var.subnet_id
  user_data                   = data.cloudinit_config.init.rendered
  user_data_replace_on_change = true
  instance_type               = var.instance_type

  tags = local.instance_tags

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
  }
}

resource "aws_eip" "nessus-scanner-eip" {
  count    = var.use_eip ? 1 : 0
  vpc      = true
  instance = aws_instance.nessus-scanner.id

  tags = {
    Name = "${local.instance_tags["Name"]}_EIP"
  }
}
