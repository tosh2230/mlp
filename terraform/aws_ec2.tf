data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "control_node" {
  ami                  = data.aws_ami.ubuntu_latest.id
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  instance_type        = var.ec2_instance_type
  subnet_id            = aws_subnet.public["public_subnet_a"].id
  vpc_security_group_ids = [
    aws_security_group.control_node.id
  ]
  key_name = var.key_name
  tags = {
    Name = "control_node"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    encrypted   = true
    volume_size = 60
    volume_type = "gp3"
    tags = {
      Name = "control_node"
    }
  }

  # prevent instance from being destroyed on changes to the below attributes
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_eip" "control_node" {
  instance = aws_instance.control_node.id
  tags = {
    Name = "control_node"
  }
}

resource "aws_security_group" "control_node" {
  name        = "control_node"
  description = "security group for control node"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "control_node_dns" {
  value = aws_instance.control_node.public_dns
}

output "control_node_ip_addr" {
  value = aws_instance.control_node.public_ip
}
