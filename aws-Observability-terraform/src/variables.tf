variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones for the VPC"
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access. Must exist in the target region."
  type        = string
  default     = "keypair"
}

variable "my_ip_cidr" {
  description = "Your IP address(Personal laptop) in CIDR notation used for locking down access to management ports."
  type        = string
  default     = "xxx.xxx.xx.xxx/32"
}

variable "custom_ip_cidr" {
  description = "A custom IP address/CIDR to allow access Prometheus and Grafana server IP."
  type        = string
  default     = "xx.xx.xxx.xx/32"
}

variable "Terraform_ip_cidr" {
  description = "A Terraform instance IP address/CIDR to allow access."
  type        = string
  default     = "yy.yyy.yyy.yy/32"
}


