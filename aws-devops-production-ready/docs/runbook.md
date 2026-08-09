# Operations Runbook

## Application unavailable
1. `docker ps -a`
2. `docker logs aws-devops-demo`
3. `./scripts/health-check.sh`
4. Check EC2 status checks and CloudWatch.
5. Verify Security Group port 8080.

## High CPU
Check `top`, `docker stats`, CloudWatch CPU metrics and application logs. Determine whether load or resource pressure is responsible before scaling.

## Security
Never commit AWS keys. Restrict SSH to your IP/32. Prefer IAM roles. Store secrets in Secrets Manager/Parameter Store. Use private subnets and centralized logging for production.

## Rollback
Use immutable image tags in production and redeploy the previous known-good tag after validation.
