# AWS DevOps Production-Ready Infrastructure

End-to-end AWS DevOps portfolio project demonstrating AWS infrastructure, Terraform, Linux, Docker, CI/CD, monitoring, security, and operational troubleshooting.

## Architecture
GitHub → CI (GitHub Actions/Jenkins) → Docker → EC2  
Terraform → VPC → Public Subnet → Security Group → EC2  
CloudWatch → infrastructure monitoring

## Skills demonstrated
AWS (VPC, EC2, IAM, S3, EBS, CloudWatch), Terraform, Linux, Bash, Docker, Kubernetes, Jenkins, Git, GitHub, CI/CD, monitoring, incident response and documentation.

## Quick start
1. Install AWS CLI, Terraform and Docker.
2. `cd terraform`
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace `YOUR_PUBLIC_IP/32`.
4. Run:
```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```
5. Build locally:
```bash
cd ../app
docker build -t aws-devops-demo .
docker run --rm -p 8080:8080 aws-devops-demo
curl http://localhost:8080/health
```

## Cleanup
```bash
cd terraform
terraform destroy
```

## Interview talking points
- Terraform makes infrastructure repeatable, reviewable and version controlled.
- Docker provides consistent application packaging.
- CI/CD automates validation and deployment.
- EC2 uses an IAM role instead of hard-coded AWS credentials.
- CloudWatch supports operational visibility.
- A production extension would add ECR, ALB, Auto Scaling, private subnets, Secrets Manager and remote Terraform state.
