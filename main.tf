

# Inputs:

variable "aws_region"             {}
variable "aws_key_name"           {}
variable "aws_key_file"           {}
variable "vpc_security_group_ids" {} # [aws_security_group.dmz.id]
variable "subnet_id"              {} # aws_subnet.dmz.id

#
# Generic Ubuntu AMI
#
# These are the region-specific IDs for an
# HVM-compatible Ubuntu image:
#
#    ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20170811
#
# The username to log into the bastion is `ubuntu'

variable "aws_ubuntu_ami" {
  default = {
    ap-northeast-1 = "ami-033cdfcdd17e140cc"
    ap-northeast-2 = "ami-0b04c9bf8abfa5b89"
    ap-south-1     = "ami-0807bb2b5888ad68c"
    ap-southeast-1 = "ami-012e97ef137a3f446"
    ap-southeast-2 = "ami-0b1f854598cf629f6"
    ca-central-1   = "ami-01428c87658222f33"
    eu-central-1   = "ami-0dfd7cad24d571c54"
    eu-west-1      = "ami-0aebeb281fdee5054"
    eu-west-2      = "ami-03f2ee00e9dc6b85f"
    sa-east-1      = "ami-0389698ad66808197"
    us-east-1      = "ami-0977029b5b13f3d08"
    us-east-2      = "ami-05f39e7b7f153bc6a"
    us-west-1      = "ami-03d5270fcb641f79b"
    us-west-2      = "ami-0f47ef92b4218ec09"
  }
}

resource "aws_instance" "bastion" {
  ami                         = lookup(var.aws_ubuntu_ami, var.aws_region)
  instance_type               = "t3.small"
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true


  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "100"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = { Name = "bastion" }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -o /usr/local/bin/jumpbox https://raw.githubusercontent.com/starkandwayne/jumpbox/master/bin/jumpbox",
      "sudo chmod 0755 /usr/local/bin/jumpbox",
      "#sudo jumpbox system"
    ]
    connection {
        type = "ssh"
        user = "ubuntu"
        host = "bastion"
        private_key = file(var.aws_key_file)
    }
  }
  provisioner "file" {
    source = var.aws_key_file
    destination = "/home/ubuntu/.ssh/bosh.pem"
    connection {
      type = "ssh"
      user = "ubuntu"
      host = "nfs-server"
      private_key = file(var.aws_key_file)
    }
  }
}


output "box-bastion-public" {
  value = aws_instance.bastion.public_ip
}