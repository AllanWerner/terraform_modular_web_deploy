data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

   filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myec2" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instancetype
  key_name               = "devops-allan"
  tags                   = var.aws_common_tags
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]

  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update -y",
        "sudo apt-get install -y nginx",
        "sudo systemctl start nginx",
        "sudo systemctl enable nginx"
    ]

    connection {
        type        = "ssh"
        user        = "ubuntu"   # utilisateur par défaut Ubuntu
        private_key = file("../../.secrets/devops-allan.pem")
        host        = self.public_ip
    }
 }
}

resource "aws_security_group" "allow_http_https_ssh" {
  name        = "allanTP3-sg"
  description = "Allow http, https and ssh inbound traffic "

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_eip" "lb" {
  instance = aws_instance.myec2.id
  provisioner "local-exec" {
    command = "echo PUBLIC IP: ${aws_eip.lb.public_ip}; ID: ${aws_instance.myec2.id}; AZ: ${aws_instance.myec2.availability_zone}; >> infos_ec2.txt"
  }
}

resource "aws_ebs_volume" "myEbsVolume" {
  availability_zone = aws_instance.myec2.availability_zone
  size              = var.ebs_volume_size
}

resource "aws_volume_attachment" "volume_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.myEbsVolume.id
  instance_id = aws_instance.myec2.id
}