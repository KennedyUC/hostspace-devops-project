terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
}

provider "kubernetes" {
  host                    = module.aws_eks_setup.cluster_endpoint
  cluster_ca_certificate  = base64decode(module.aws_eks_setup.cluster_certificate_authority_data)
  exec {
    api_version           = "client.authentication.k8s.io/v1beta1"
    args                  = ["eks", "get-token", "--cluster-name", "${var.project_name}-${var.env}-k8s"]
    command               = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                    = module.aws_eks_setup.cluster_endpoint
    cluster_ca_certificate  = base64decode(module.aws_eks_setup.cluster_certificate_authority_data)
    exec {
      api_version           = "client.authentication.k8s.io/v1beta1"
      args                  = ["eks", "get-token", "--cluster-name", "${var.project_name}-${var.env}-k8s"]
      command               = "aws"
    }
  }
}