locals {
  mng_defaults = {
    dedicated_node_role = null
    instance_type       = "t3.small"
    gpu_accelerator     = ""
    gpu_count           = 0
    min_size            = 0
    max_size            = 1
    root_disk_size_gb   = 20
    local_ssd_size_gb   = 0
    spot                = false
    subnet_ids          = module.vpc.private_subnets
  }
  mngs = {
    services = {
      max_size = 1
      min_size = 1
    }
  }
  _mngs_with_defaults = {
    for k, v in local.mngs : k => merge(local.mng_defaults, v)
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name                    = local.name_prefix
  cluster_version                 = "1.24"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    for k, v in local._mngs_with_defaults : k => {
      desired_size = v.min_size
      max_size     = v.max_size
      min_size     = v.min_size

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = v.root_disk_size_gb
          }
        }
      }
      capacity_type  = v.spot ? "SPOT" : "ON_DEMAND"
      instance_types = [v.instance_type]
    }
  }
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

data "http" "alb-controller-policy-source" {
  url    = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json"
  method = "GET"
}

resource "aws_iam_policy" "aws-load-balancer-controller-iam-policy" {
  name   = "${local.name_prefix}-alb-policy"
  policy = data.http.alb-controller-policy-source.response_body
}

resource "aws_iam_role_policy_attachment" "alb-policy-attachment" {
  role       = module.aws_load_balancer_controller_irsa_role.iam_role_name
  policy_arn = aws_iam_policy.aws-load-balancer-controller-iam-policy.arn
}

module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.11.2"

  role_name                              = "${local.name_prefix}-aws-load-balancer-controller"
  attach_load_balancer_controller_policy = false

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  namespace = "kube-system"
  wait      = true
  timeout   = 600

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.7"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}
