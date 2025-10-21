locals {
  common_tags = {
    CreatedBy = "Silambarasan_A"
    Purpose   = "Infrastructure creation using Terraform"
  }
}

# Find latest Ubuntu AMI from Canonical
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "simbu-vpc"
  })
}

# 2. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "simbu-ig-terraform"
  })
}

# 3. Public Subnets (one in each AZ)
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "Simbu-Public-Subnet-${count.index + 1}"
  })
}

# 4. Route Table for public traffic
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(local.common_tags, {
    Name = "Simbu-Public-Route-Table"
  })
}

# 5. Associate Route Table with Subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 6. Security Group to allow HTTP and SSH
resource "aws_security_group" "web_sg" {
  name        = "simbu-Web-Server-SG"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Ingress rules configured per user's manual changes
  ingress {
    description = "Node Exporter (9100) from my IP"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Prometheus (9090) from my IP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Grafana (3000) from my IP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Node Exporter (9100) from custom IP"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.custom_ip_cidr]
  }

  ingress {
    description = "Prometheus (9090) from custom IP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.custom_ip_cidr]
  }

  ingress {
    description = "Grafana (3000) from custom IP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.custom_ip_cidr]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "SSH from my Terraform to Servers"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.Terraform_ip_cid]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "simbu-Web-Server-SG"
  })
}

# 7. EC2 Instances - two explicit instances with different sizes and names
resource "aws_instance" "simbu_node_exporter" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("${path.module}/userdata.sh")

  tags = merge(local.common_tags, {
    Name = "Simbu-NodeExporter"
    nightshift = "false"
  })
}

resource "aws_instance" "simbu_prometheus_grafana" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t2.medium"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("${path.module}/userdata.sh")

  tags = merge(local.common_tags, {
    Name = "Simbu-Prometheus-Grafana"
    nightshift = "false"
  })
}

resource "aws_eip" "node_exporter_eip" {
  instance = aws_instance.simbu_node_exporter.id
  vpc      = true
}

resource "aws_eip" "prometheus_grafana_eip" {
  instance = aws_instance.simbu_prometheus_grafana.id
  vpc      = true
}

data "aws_route53_zone" "observability" {
  name         = "observability.com"
  private_zone = false
}

resource "aws_route53_record" "node_exporter_dns" {
  zone_id = data.aws_route53_zone.observability.zone_id
  name    = "node-exporter.observability.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.node_exporter_eip.public_ip]
}

resource "aws_route53_record" "prometheus_grafana_dns" {
  zone_id = data.aws_route53_zone.observability.zone_id
  name    = "grafana-prometheus.observability.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.prometheus_grafana_eip.public_ip]
}

# Generate an Ansible inventory file with the public IPs created by Terraform
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.tpl", {
    node_ip = aws_eip.node_exporter_eip.public_ip,
    prom_ip = aws_eip.prometheus_grafana_eip.public_ip,
    ssh_user = "ubuntu"
  })

  filename = "${path.module}/ansible/inventory.ini"
}
