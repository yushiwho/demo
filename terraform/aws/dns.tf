data "aws_route53_zone" "zone" {
  name = var.zone_name
}

resource "aws_route53_record" "cname_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300

  records = [var.alb_address]

  allow_overwrite = true
}

resource "aws_acm_certificate" "demo_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

module "external_dns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.11.2"

  role_name                     = "demo-external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = [data.aws_route53_zone.zone.arn]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
}

resource "helm_release" "external_dns" {
  namespace = "kube-system"
  wait      = true
  timeout   = 600

  name = "external-dns"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.12.1"

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_dns_irsa_role.iam_role_arn
  }
}

output "aws_acm_certificate" {
  value = [aws_acm_certificate.demo_cert.arn]
}
