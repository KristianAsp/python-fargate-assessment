# python-fargate-assessment

## Implementation Overview

The following implementation overview is based on the provided instructions for this platform assessment. It is broken down into smaller, logical tasks

- [x] Setup local virtualenv
- [x] Dockerize Service
    - [x] Minimal working Dockerfile that will install dependencies and run a Flask application
- [] Deploy to Fargate (manual)
- [] Create Terraform manifests
- [] CI/CD Workflows
    - [x] Testing Application
    - [x] Linting
    - [x] Docker Build
    - [] Terraform Deployment

### Notes

**Overall Notes**
* Use `ap-southeast-1` i.e. Singapore region for everything

**Dockerizing Service**
* This should be pushed to ECR
    - Do we have credentials for this?
    - An ECR repo exists - `ecr-tprepo`
        * Not mentioned in the docs but has permissions to
            * List Repositories
            * Initiate Layer Upload (so likely we have permission to push images)
            * We **do not** have permissions to list images. 

**CI/CD**
* Four workflows
    - Testing Application
    - Linting
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
* Three available subnets across 3 AZs. All 3 subnets are public. 

### Improvements

##### Networking
* Put ECS tasks in a private subnet - no needto have them in a public subnets
* 