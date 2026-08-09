# AWS DevOps Production-Ready Infrastructure
## End-to-End Project Documentation

This document explains the portfolio project in practical, practical project language.

---

# 1. Project Overview

## Project Name
AWS DevOps Production-Ready Infrastructure

## Project Goal

The goal is to demonstrate an end-to-end DevOps workflow for a small containerized application running on AWS.

The project combines:

- AWS infrastructure
- Terraform
- Linux
- Bash
- Docker
- Git/GitHub
- Jenkins
- GitHub Actions
- IAM
- VPC networking
- CloudWatch monitoring
- Operational troubleshooting

The repository is intentionally small enough to understand completely while still demonstrating the core responsibilities expected from an AWS/DevOps engineer.

## One-line project explanation

> "I built a Terraform-managed AWS environment where a containerized application can be validated through CI/CD, deployed on EC2, monitored operationally, and supported using Linux and Bash."

---

# 2. Architecture

High-level flow:

Developer
   |
   v
GitHub
   |
   +--------------------+
   |                    |
   v                    v
Jenkins              GitHub Actions
   |                    |
   +---------+----------+
             |
             v
       Docker Build
             |
             v
       Container Image
             |
             v
        AWS EC2
             |
             v
       Application :8080

Terraform provisions:

AWS Region
   |
   v
VPC 10.20.0.0/16
   |
   +--> Public Subnet 10.20.1.0/24
   |
   +--> Internet Gateway
   |
   +--> Route Table
   |
   +--> Security Group
   |
   +--> IAM Role
   |
   +--> EC2

CloudWatch is used for operational visibility.

---

# 3. Why These Technologies?

## AWS

AWS provides the cloud infrastructure used by the project.

Services used in the project include:

- VPC
- EC2
- IAM
- EBS through the EC2 instance
- CloudWatch
- Security Groups

## Terraform

Terraform is used to define infrastructure as code.

Instead of manually creating resources through the AWS console, the configuration describes the desired infrastructure.

Benefits:

- Repeatability
- Version control
- Reviewability
- Consistent environments
- Easier cleanup

## Docker

The application is packaged into a Docker image.

This makes the runtime environment consistent between development, CI and the EC2 host.

## GitHub

GitHub stores the source code and enables pull requests and CI automation.

## Jenkins

The Jenkinsfile demonstrates a traditional CI pipeline:

1. Checkout
2. Python syntax validation
3. Docker build
4. Container smoke test

## GitHub Actions

The workflow provides the same type of automated validation directly from GitHub.

## Linux

The EC2 instance uses Amazon Linux and the bootstrap script installs Docker and enables the Docker service.

## Bash

Bash scripts automate deployment and health checks.

## CloudWatch

CloudWatch provides operational monitoring for AWS infrastructure. The repository also contains a CloudWatch Agent configuration for host-level CPU, memory and disk metrics.

---

# 4. Repository Structure

```text
aws-devops-production-ready/
│
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── src/
│       └── app.py
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── terraform.tfvars.example
│
├── scripts/
│   ├── deploy.sh
│   └── health-check.sh
│
├── jenkins/
│   └── Jenkinsfile
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── monitoring/
│   └── cloudwatch-agent.json
│
├── docs/
│   ├── runbook.md
│   └── PROJECT_GUIDE_AND_INTERVIEW_NOTES.md
│
├── .gitignore
└── README.md
```

---

# 5. Application

The application is a small Flask service.

It exposes:

```text
GET /
GET /health
```

The root endpoint returns basic application information.

The health endpoint returns:

```json
{
  "status": "healthy"
}
```

This endpoint is important because automation can use it to determine whether the application is responding correctly.

---

# 6. Docker

The Dockerfile:

1. Uses Python 3.12 slim.
2. Creates `/app` as the working directory.
3. Installs dependencies.
4. Copies the application.
5. Creates a non-root user.
6. Exposes port 8080.
7. Defines a Docker health check.
8. Starts the Flask application.

## Why run as a non-root user?

Running application processes as a non-root user reduces unnecessary privileges inside the container.

## Practical explanation

**Q: Why Docker?**

> "Docker packages the application and its dependencies into a consistent runtime unit, which makes testing and deployment more predictable across environments."

---

# 7. Terraform Infrastructure

Terraform creates the AWS foundation.

## VPC

CIDR:

```text
10.20.0.0/16
```

The VPC provides isolated networking for the project.

## Public subnet

CIDR:

```text
10.20.1.0/24
```

The subnet has public IP assignment enabled because this demo uses a directly reachable EC2 instance.

## Internet Gateway

The Internet Gateway allows internet connectivity for the public subnet.

## Route table

The route table contains:

```text
0.0.0.0/0 -> Internet Gateway
```

This provides a default route to the internet.

## Security Group

The security group allows:

```text
TCP 8080 -> application
TCP 22   -> SSH from configured CIDR
```

SSH should be restricted to the administrator's public IP.

Never use:

```text
0.0.0.0/0
```

for SSH in a real environment.

---

# 8. IAM

The EC2 instance receives an IAM role through an instance profile.

The project intentionally avoids putting AWS access keys inside scripts or source code.

## Practical explanation

**Q: Why use an IAM role instead of AWS access keys?**

> "An IAM role allows the EC2 workload to obtain temporary credentials through AWS instead of storing long-lived access keys in configuration files or scripts."

The current demo role is intentionally minimal and does not grant broad AWS permissions.

---

# 9. EC2 Bootstrap

Terraform uses EC2 user data.

The bootstrap process:

```text
Launch EC2
   |
   v
Install Docker
   |
   v
Enable Docker service
   |
   v
Add ec2-user to docker group
```

This demonstrates infrastructure initialization through automation rather than manually installing Docker after every instance launch.

---

# 10. Terraform Deployment Process

From the `terraform` directory:

```bash
terraform init
```

### What it does

Downloads the required provider and initializes the Terraform working directory.

---

```bash
terraform fmt -recursive
```

Formats Terraform files consistently.

---

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically and structurally valid.

---

```bash
terraform plan
```

Shows what Terraform intends to create, modify or destroy.

---

```bash
terraform apply
```

Creates the infrastructure after confirmation.

---

# 11. Important Terraform Technical Notes

## What is Terraform state?

Terraform state records the relationship between the configuration and resources Terraform manages.

## Why should state not be committed to Git?

State can contain infrastructure details and may contain sensitive information depending on configuration.

The repository therefore ignores:

```text
*.tfstate
*.tfstate.*
```

## What would you use in production?

A production implementation would normally use remote state with controlled access and state locking rather than keeping state only on a local workstation.

---

# 12. Docker Build

From the project root:

```bash
docker build -t aws-devops-demo ./app
```

Run:

```bash
docker run --rm -p 8080:8080 aws-devops-demo
```

Test:

```bash
curl http://localhost:8080/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

---

# 13. CI/CD Pipeline

The project contains two CI examples.

## GitHub Actions

The workflow performs:

```text
Checkout
   |
   v
Python syntax check
   |
   v
Docker build
   |
   v
Container smoke test
```

The purpose is to automatically validate changes whenever code is pushed to `main` or a pull request is opened.

## Jenkins

The Jenkinsfile demonstrates the same fundamental pipeline:

```text
Checkout
   ↓
Validate
   ↓
Docker Build
   ↓
Smoke Test
```

---

# 14. What Is a Smoke Test?

A smoke test is a quick check that confirms the application starts and responds to a basic request.

This project uses:

```bash
curl --fail http://localhost:18080/health
```

If the health endpoint fails, the pipeline fails.

## Practical explanation

> "I use a smoke test after building the container so the pipeline verifies that the image can actually start and serve the application before it is considered valid."

---

# 15. Deployment Script

The deployment script:

```text
Build image
   ↓
Stop old container
   ↓
Remove old container
   ↓
Start new container
```

It also uses:

```text
--restart unless-stopped
```

so Docker attempts to restart the application after a container or host restart.

---

# 16. Health Check

The health-check script accepts a URL.

Default:

```text
http://localhost:8080/health
```

It uses curl with failure handling.

If the endpoint is healthy:

```text
Health check passed
```

Otherwise the script exits with a non-zero status.

This makes it suitable for automation.

---

# 17. Monitoring

The project includes a CloudWatch Agent configuration.

Metrics include:

- CPU
- Memory
- Disk usage

## Why monitoring matters

Infrastructure administration is not only about deployment.

An administrator needs to identify:

- Resource pressure
- Application availability issues
- CPU spikes
- Disk exhaustion
- Operational failures

The project also recommends checking:

```text
EC2 status checks
CloudWatch metrics
Docker logs
Application health endpoint
```

during troubleshooting.

---

# 18. Incident Troubleshooting

Suppose the application is unavailable.

Use this sequence.

## Step 1 — Check container

```bash
docker ps -a
```

Look for:

- Exited container
- Restart loops
- Missing container

## Step 2 — Check logs

```bash
docker logs aws-devops-demo
```

Look for:

- Python errors
- Dependency problems
- Port conflicts
- Application startup failures

## Step 3 — Check health

```bash
./scripts/health-check.sh
```

## Step 4 — Check EC2

Review:

- Instance state
- Status checks
- CPU
- Network connectivity

## Step 5 — Check Security Group

Confirm port 8080 is allowed.

## Step 6 — Check Docker

```bash
systemctl status docker
```

## Step 7 — Restart only after identifying the problem

```bash
docker restart aws-devops-demo
```

The important interview principle is:

> Diagnose first, restart second.

---

# 19. Security Considerations

This portfolio project intentionally demonstrates several security practices.

## IAM role

No static AWS keys are embedded in the EC2 deployment.

## SSH restriction

SSH access is configured using:

```text
YOUR_PUBLIC_IP/32
```

instead of opening port 22 globally.

## Git protection

`.gitignore` excludes:

```text
*.tfstate
*.tfvars
*.pem
.env
```

## Container user

The application container runs as a non-root user.

---

# 20. What Is NOT Production-Ready Yet?

Be honest about this in interviews.

The project is a portfolio demonstration, not a complete enterprise platform.

A production evolution would add:

- Amazon ECR
- Application Load Balancer
- Auto Scaling Group
- Private application subnets
- NAT Gateway where required
- Secrets Manager or Parameter Store
- Remote Terraform state
- Centralized logging
- CloudTrail
- Vulnerability scanning
- Image tagging strategy
- Deployment approvals
- Blue/green or rolling deployments
- Multi-AZ architecture

Do not claim these features are already implemented unless you actually add them.

---

# 21. How to Explain the Entire Project in 60 Seconds

Use this answer:

> "I built an end-to-end AWS DevOps project to demonstrate infrastructure automation and operational support. I used Terraform to provision a VPC, public subnet, routing, security group, IAM role and EC2 instance. I containerized a small Flask application with Docker and created CI pipelines using GitHub Actions and Jenkins for validation, Docker builds and smoke testing. I also added Bash deployment and health-check scripts and a CloudWatch Agent configuration for infrastructure monitoring. The project helped me practice AWS administration, Linux, Terraform, Docker, CI/CD, troubleshooting and operational security."

---

# 22. 30-Second Version

> "It's a Terraform-managed AWS environment running a Dockerized application on EC2. GitHub Actions and Jenkins validate the application, Bash handles deployment and health checks, and CloudWatch provides monitoring. The project demonstrates AWS infrastructure, Linux, Docker, Terraform and CI/CD skills."

---

# 23. Likely Technical Notes

## AWS

### Q1. Why did you choose EC2?

> "EC2 gives direct control over the operating system and container runtime, which makes it useful for demonstrating Linux administration and infrastructure operations."

### Q2. What is a Security Group?

> "A Security Group acts as a stateful virtual firewall for resources such as EC2 and controls inbound and outbound traffic."

### Q3. What is the difference between a Security Group and NACL?

> "A Security Group is associated with an ENI/resource and is stateful. A Network ACL operates at the subnet level and is stateless."

### Q4. Why VPC?

> "VPC provides isolated networking and lets us control subnets, routes and traffic boundaries."

---

# 24. Terraform Technical Notes

### Q. Why Terraform instead of manual AWS console work?

> "Terraform makes infrastructure repeatable and version controlled. Changes can be reviewed through code before they are applied."

### Q. What does terraform plan do?

> "It creates an execution plan showing the infrastructure changes Terraform intends to make."

### Q. What does terraform destroy do?

> "It removes resources managed by the Terraform configuration. I use it for cleanup in this portfolio project to avoid unnecessary AWS cost."

---

# 25. Docker Technical Notes

### Q. Container vs virtual machine?

> "A VM virtualizes a complete operating system, while a container shares the host kernel and isolates the application process and dependencies."

### Q. Why use a health check?

> "It provides an automated signal indicating whether the application is responding correctly."

---

# 26. CI/CD Technical Notes

### Q. What happens when code is pushed?

> "The GitHub Actions workflow checks out the code, validates Python syntax, builds the Docker image and runs a container smoke test."

### Q. Why have both Jenkins and GitHub Actions?

> "The project demonstrates both common CI approaches. In a real team I would normally standardize on the organization's selected platform rather than unnecessarily maintaining both."

This is a strong Practical explanation because it shows practical judgment.

---

# 27. Linux Technical Notes

### Useful commands

Check processes:

```bash
ps aux
```

Check CPU/memory:

```bash
top
```

Check disk:

```bash
df -h
```

Check memory:

```bash
free -m
```

Check Docker:

```bash
docker ps
docker stats
```

Check service:

```bash
systemctl status docker
```

Check logs:

```bash
docker logs <container>
```

Test connectivity:

```bash
curl
```

---

# 28. Bash Technical Notes

### Why use Bash?

> "Bash is useful for automating repetitive Linux operational tasks such as deployment, health checks and service validation."

### Why use `set -euo pipefail`?

> "It makes the script fail more predictably by stopping on errors, treating unset variables as errors and detecting failures inside pipelines."

---

# 29. Incident Management Story

If asked:

**"Tell me about a production troubleshooting approach."**

Use this project example:

> "I follow a structured troubleshooting process. I first confirm the impact, then check the application health endpoint, container status and logs. If the application appears healthy, I move down the infrastructure layer by checking EC2 status, CPU, memory, networking and Security Group configuration. I document the symptoms and root cause before applying a corrective action."

This demonstrates an operational mindset without claiming a real incident that did not happen.

---

# 30. Cost Awareness

The project uses a small EC2 instance for demonstration.

Before creating AWS resources:

- Check the AWS pricing for the selected region.
- Use the smallest suitable resources.
- Destroy resources when finished.

After the demo:

```bash
terraform destroy
```

Never leave cloud resources running unnecessarily.

---

# 31. GitHub Presentation

Your GitHub repository should contain:

1. Clear README
2. Architecture diagram
3. Repository structure
4. Terraform code
5. Dockerfile
6. CI/CD pipeline
7. Bash scripts
8. Monitoring configuration
9. Troubleshooting runbook
10. Screenshots of successful execution

Recommended screenshots:

- Terraform plan
- Terraform apply output
- AWS EC2 instance
- AWS VPC
- Docker container running
- `/health` response
- GitHub Actions successful run
- Jenkins successful build
- CloudWatch metrics

Only upload screenshots from your own actual deployment.

---

# 32. Resume Bullet

Once you have actually deployed and tested the project, a truthful resume bullet can be:

> **Built an AWS DevOps infrastructure project using Terraform, Docker, Jenkins, GitHub Actions, Linux, Bash and CloudWatch, automating infrastructure provisioning, CI validation, deployment and health checks.**

If you have not personally deployed/tested a feature, describe it as a project implementation rather than claiming production usage.

---

# 33. Final Project Validation Checklist

Before putting the project on your resume, make sure you can explain:

- [ ] VPC
- [ ] Subnet
- [ ] Route table
- [ ] Internet Gateway
- [ ] Security Group
- [ ] EC2
- [ ] IAM role
- [ ] EBS
- [ ] CloudWatch
- [ ] Terraform state
- [ ] Terraform plan/apply
- [ ] Docker image vs container
- [ ] Dockerfile
- [ ] Health check
- [ ] Jenkins pipeline
- [ ] GitHub Actions
- [ ] CI/CD
- [ ] Bash scripts
- [ ] Linux troubleshooting
- [ ] Incident management
- [ ] Security considerations
- [ ] Production improvements

---

# 34. Implementation Note

Do not memorize the project as a script.

Understand the flow:

```text
Code
 ↓
GitHub
 ↓
CI validation
 ↓
Docker image
 ↓
AWS infrastructure
 ↓
EC2
 ↓
Application
 ↓
Health check
 ↓
Monitoring
 ↓
Troubleshooting
```

If you understand that flow and can explain why each component exists, you can confidently discuss the project in an interview.
