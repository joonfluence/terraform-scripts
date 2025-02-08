# AWS Provider 설정
provider "aws" {
  region = "ap-northeast-2"  # 원하는 AWS 리전으로 변경 가능
}

# VPC 생성
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

# 서브넷 생성
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"
}

# IAM 역할 생성
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# EKS 클러스터 생성
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public1.id,  # ap-northeast-2a
      aws_subnet.public2.id   # ap-northeast-2b (다른 AZ에 있어야 함)
    ]
  }
}