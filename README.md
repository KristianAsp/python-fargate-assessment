# python-fargate-assessment

## Implementation Overview

The following implementation overview is based on the provided instructions for this platform assessment. It is broken down into smaller, logical tasks

- [] Setup local virtualenv
- [] Dockerize Service
- [] Deploy to Fargate (manual)
- [] Create Terraform manifests
- [] CI/CD Workflows
    - [] Testing Application
    - [] Docker Build
    - [] Terraform Deployment

### Notes

**Dockerizing Service**
- This should be pushed to ECR
    - Do we have credentials for this?

**CI/CD**
* Three workflows
    - Testing Application
    - Docker Build & ECR push
    - Terraform Deployment
* Testing should be triggered automatically on each Pull Request
    * If failed, merge should not be possible
* On merge, the docker build & deployment should trigger automatically

**Deploying with Terraform**
* A default VPC is provided - use that
* Max 2 replicas
* Fargate needs to pull from ECR
* The following permissions are granted
    - `ecs:*`
    - `ec2:*`
    - `elb:*`
    - `elbv2:*`
    - `vpc:*`
    - `iam:Read*` on `ecsTaskExecutionRole`
    - Permissions to manage IAM credentials for the provided user