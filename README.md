# AWS Terraform Infrastructure

This repository contains Terraform (HCL) code to provision and manage AWS infrastructure using Infrastructure as Code (IaC). The project includes reusable modules for networking, compute, security, and high availability architectures following Terraform best practices.

## Features

- AWS Infrastructure
- Modular Terraform code
- Reusable Terraform modules
- High Availability (Multi-AZ) architectures
- Security Groups, VPCs, EC2, Load Balancers, Auto Scaling, and more

## Repository Structure

```text
.
├── modules/
│   ├── Compute/
│   ├── Database/
│   └── Network/
├── environments/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## Prerequisites

- Terraform >= 1.5
- AWS CLI
- AWS Account
- Git

## Usage

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

## Technologies Used

- Terraform (HCL)
- AWS
- Git & GitHub

## Author

Syed Nasr Jilani
