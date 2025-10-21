# AWS VPC Terraform Setup

This project sets up a single Virtual Private Cloud (VPC) in an AWS environment using Terraform.

## Project Structure

```
aws-vpc-terraform
├── src
│   ├── main.tf          # Main configuration for creating the VPC
│   ├── variables.tf     # Input variables for the Terraform configuration
│   ├── outputs.tf       # Outputs of the Terraform configuration
│   └── provider.tf      # AWS provider configuration
└── README.md            # Project documentation
```

...existing code...

## Getting Started

### Prerequisites

- Terraform installed on the machine (recommended v1.x).
- An EC2 instance (or workstation) with network access to AWS.
- If running from an EC2 instance: attach an IAM role (instance profile) that has permissions to create VPC, subnets, route tables, and related networking resources. When an appropriate instance profile is attached, no AWS access keys are required on the instance.
- AWS CLI is optional but can help verify which identity the instance is using: aws sts get-caller-identity

### Running from an EC2 instance with an IAM role

When Terraform runs on an EC2 instance that has an attached IAM role, the AWS provider will automatically use the instance metadata credentials. Recommended steps:

1. Connect to the EC2 instance (e.g., ec2-user@<instance-ip>).
2. Ensure Terraform is installed on the instance.
3. Ensure the instance has an IAM role with the required permissions.
4. Set the AWS region (if not configured in provider.tf):
   - export AWS_DEFAULT_REGION=us-east-1
   or set the region in provider.tf variables.

5. Change into the Terraform configuration directory and run:

```bash
cd /path/to/aws-Observability-terraform/src
terraform init
terraform plan
terraform apply -auto-approve
```

6. View outputs:

```bash
terraform output
```

Notes:
- No AWS credentials (AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY) are required on the instance when using an attached IAM role.
- The instance must be able to reach the Instance Metadata Service (IMDS) to retrieve role credentials.

### State management

This repository uses local state by default (unless you have a backend configured in provider.tf). For running Terraform from an EC2 instance or in a team, use a remote backend (S3 + DynamoDB locking) to avoid state conflicts. Example backend block (place in a backend.tf file):

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "aws-Observability-terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Cleanup

To remove the created infrastructure:

```bash
terraform destroy -auto-approve
```

Type `yes` if prompted (or use -auto-approve).

### Troubleshooting

- If Terraform cannot authenticate on EC2, verify the instance profile is attached and that the instance can access IMDS (check IMDSv2 requirements).
- Use `aws sts get-caller-identity` to confirm the identity Terraform will use.
- Consider enabling verbose logging for Terraform: `TF_LOG=DEBUG terraform apply`.
