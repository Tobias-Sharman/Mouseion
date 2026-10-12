locals {
  dns_enabled = var.domain_name != null
}

resource "aws_route53_zone" "public" {
  count = local.dns_enabled ? 1 : 0
  name  = var.domain_name

  tags = { Name = "${var.project_name}-zone" }
}

resource "aws_acm_certificate" "website" {
  count                     = local.dns_enabled ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "${var.project_name}-cert-website" }
}

resource "aws_route53_record" "website_cert_validation" {
  for_each = {
    for option in(local.dns_enabled ? aws_acm_certificate.website[0].domain_validation_options : []) :
    option.domain_name => option
  }
  zone_id         = aws_route53_zone.public[0].zone_id
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  records         = [each.value.resource_record_value]
  ttl             = 300
  allow_overwrite = true
}

# Blocks until the registrar points the domain at this zone's name servers
resource "aws_acm_certificate_validation" "website" {
  count                   = local.dns_enabled ? 1 : 0
  certificate_arn         = aws_acm_certificate.website[0].arn
  validation_record_fqdns = [for record in aws_route53_record.website_cert_validation : record.fqdn]
}

data "aws_iam_policy_document" "external_dns" {
  count = local.dns_enabled ? 1 : 0

  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [aws_route53_zone.public[0].arn]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "external_dns" {
  count  = local.dns_enabled ? 1 : 0
  name   = "external-dns"
  role   = aws_iam_role.irsa["external-dns"].id
  policy = data.aws_iam_policy_document.external_dns[0].json
}
