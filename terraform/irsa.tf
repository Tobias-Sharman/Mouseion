data "aws_caller_identity" "current" {}

locals {
  oidc_issuer_host = aws_s3_bucket.oidc.bucket_regional_domain_name
  oidc_issuer_url  = "https://${local.oidc_issuer_host}"

  irsa_service_accounts = merge(
    {
      ebs-csi-driver               = { namespace = "kube-system", name = "ebs-csi-controller-sa" }
      aws-load-balancer-controller = { namespace = "kube-system", name = "aws-load-balancer-controller" }
    },
    local.dns_enabled ? {
      external-dns = { namespace = "external-dns", name = "external-dns" }
    } : {}
  )
}

# Public by design, AWS STS fetches these anonymously to verify service account tokens
resource "aws_s3_bucket" "oidc" {
  bucket        = "${var.project_name}-oidc-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = { Name = "${var.project_name}-oidc" }
}

resource "aws_s3_bucket_public_access_block" "oidc" {
  bucket                  = aws_s3_bucket.oidc.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "oidc_public_read" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.oidc.arn}/.well-known/openid-configuration",
      "${aws_s3_bucket.oidc.arn}/keys.json",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "oidc" {
  bucket     = aws_s3_bucket.oidc.id
  policy     = data.aws_iam_policy_document.oidc_public_read.json
  depends_on = [aws_s3_bucket_public_access_block.oidc]
}

# keys.json is uploaded by Ansible once the service account signing key exists
resource "aws_s3_object" "oidc_discovery" {
  bucket       = aws_s3_bucket.oidc.id
  key          = ".well-known/openid-configuration"
  content_type = "application/json"
  content = jsonencode({
    issuer                                = local.oidc_issuer_url
    jwks_uri                              = "${local.oidc_issuer_url}/keys.json"
    response_types_supported              = ["id_token"]
    subject_types_supported               = ["public"]
    id_token_signing_alg_values_supported = ["RS256"]
  })
}

resource "aws_iam_openid_connect_provider" "cluster" {
  url            = local.oidc_issuer_url
  client_id_list = ["sts.amazonaws.com"]
  # IAM fetches the discovery document when the provider is created
  depends_on = [aws_s3_object.oidc_discovery, aws_s3_bucket_policy.oidc]
}

data "aws_iam_policy_document" "irsa_assume" {
  for_each = local.irsa_service_accounts

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  for_each           = local.irsa_service_accounts
  name               = "${var.project_name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume[each.key].json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.irsa["ebs-csi-driver"].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy" "aws_load_balancer_controller" {
  name   = "aws-load-balancer-controller"
  role   = aws_iam_role.irsa["aws-load-balancer-controller"].id
  policy = file("${path.module}/policies/aws_load_balancer_controller.json")
}
