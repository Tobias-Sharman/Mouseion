data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Only host network components (CCM, cilium-operator) reach this, pods are blocked by the IMDS hop limit
resource "aws_iam_role" "controller" {
  name               = "${var.project_name}-controller"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_instance_profile" "controller" {
  name = "${var.project_name}-controller"
  role = aws_iam_role.controller.name
}

resource "aws_iam_role_policy" "controller_cloud_controller_manager" {
  name   = "cloud-controller-manager"
  role   = aws_iam_role.controller.id
  policy = file("${path.module}/policies/aws_cloud_controller_manager.json")
}

data "aws_iam_policy_document" "cilium_operator" {
  statement {
    actions = [
      "ec2:AssignPrivateIpAddresses",
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:CreateTags",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:UnassignPrivateIpAddresses",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "controller_cilium_operator" {
  name   = "cilium-operator"
  role   = aws_iam_role.controller.id
  policy = data.aws_iam_policy_document.cilium_operator.json
}
