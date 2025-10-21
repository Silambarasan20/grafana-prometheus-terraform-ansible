output "vpc_name" {
  description = "The Name tag of the created VPC"
  value       = aws_vpc.main.tags["Name"]
}

output "internet_gateway_name" {
  description = "The Name tag of the Internet Gateway"
  value       = aws_internet_gateway.gw.tags["Name"]
}

output "public_subnet_names" {
  description = "List of Name tags for the public subnets"
  value       = aws_subnet.public[*].tags["Name"]
}

output "route_table_name" {
  description = "The Name tag of the public route table"
  value       = aws_route_table.public.tags["Name"]
}

output "security_group_name" {
  description = "The Name of the web server security group"
  value       = aws_security_group.web_sg.name
}
output "instance_names" {
  description = "List of Name tags for the EC2 instances"
  value = [
    aws_instance.simbu_node_exporter.tags["Name"],
    aws_instance.simbu_prometheus_grafana.tags["Name"],
  ]
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances. Use one of these IPs to connect (SSH/HTTP/Prometheus/Grafana)."
  value = [
    aws_instance.simbu_node_exporter.public_ip,
    aws_instance.simbu_prometheus_grafana.public_ip,
  ]
}

output "instance_public_dns" {
  description = "Public DNS names of the EC2 instances"
  value = [
    aws_instance.simbu_node_exporter.public_dns,
    aws_instance.simbu_prometheus_grafana.public_dns,
  ]
}

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value = [
    aws_instance.simbu_node_exporter.id,
    aws_instance.simbu_prometheus_grafana.id,
  ]
}

output "node_exporter_dns" {
  value = aws_route53_record.node_exporter_dns.name
}

output "prometheus_grafana_dns" {
  value = aws_route53_record.prometheus_grafana_dns.name
}
