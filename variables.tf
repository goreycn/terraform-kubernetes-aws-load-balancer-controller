

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "prefix_separator" {
  description = "The separator to use between the prefix and the generated timestamp for resource names"
  type        = string
  default     = "-"
}

################################################################################
# aws-load-balancer-controller
################################################################################
variable "name" {
  description = "The name of the Controller"
  type        = string
  default     = "aws-load-balancer-controller"

}

variable "namespace" {
  description = "The namespace to place the controller"
  type        = string
  default     = "kube-system"

}

variable "image_name" {
  description = "the name of the container image to use"
  type        = string
  default     = "aws-alb-ingress-controller"

}

variable "image_version" {
  description = "The version of the conatiner image to use"
  type        = string
  default     = "v2.3.1"

}

################################################################################
# IAM Role Variables
################################################################################

variable "create_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role for the aws-load-balancer-controller"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the aws-load-balancer-controller. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = "/eks/"
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = "Permissions required by the Kubernetes aws-load-balancer-controller to do it's job."
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# EKS
################################################################################

variable "eks_cluster_name" {

}
