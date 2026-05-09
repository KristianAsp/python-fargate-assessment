variable "image_tag" {
  description = "Short git SHA of the image to deploy"
  type        = string
}

variable "ecr_repository_url" {
  description = "Full ECR repository URL (without tag)"
  type        = string
}
