module "prod-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "prod-vpc"

  cidr = var.aws_vpc_cidr_block
  azs  = slice(data.aws_availability_zones.aws-availability-zones.names, 0, 2)

  private_subnets = var.aws_vpc_private_subnets
  public_subnets  = var.aws_vpc_public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.aws_eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                            = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.aws_eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                   = 1
  }
}

module "aws-eks-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.4.0"

  cluster_name    = var.aws_eks_cluster_name
  cluster_version = var.aws_eks_cluster_version

  vpc_id                         = module.prod-vpc.vpc_id
  subnet_ids                     = module.prod-vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = [var.aws_eks_ec2_instance_type]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
    two = {
      name           = "node-group-2"
      instance_types = [var.aws_eks_ec2_instance_type]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}

module "aws-eks-irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.aws-eks-cluster.cluster_name}"
  provider_url                  = module.aws-eks-cluster.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.aws-eks-irsa-ebs-csi-policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "aws-eks-ebs-csi" {
  cluster_name             = module.aws-eks-cluster.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.aws-eks-irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}