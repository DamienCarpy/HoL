# Declare AWS provider
provider "aws" {
  region = var.aws_region
}

# Get user identity & environment
data "aws_caller_identity" "current" {}

# Define policy
data "aws_iam_policy_document" "students" {
  statement {
    actions = [
      "ec2:CreateTags",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSubnet",
      "ec2:CreateVpc",
      "ec2:AttachInternetGateway",
      "ec2:DescribeVpcAttribute",
      "ec2:ReplaceRoute",
      "ec2:DeleteRouteTable",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:AssociateRouteTable",
      "ec2:CreateRoute",
      "ec2:CreateInternetGateway",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:ModifyVpcAttribute",
      "ec2:DeleteInternetGateway",
      "ec2:ModifyInstanceAttribute",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:TerminateInstances",
      "ec2:DeleteRoute",
      "ec2:CreateRouteTable",
      "ec2:RunInstances",
      "ec2:ModifySecurityGroupRules",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVpc",
      "ec2:CreateSubnet",
      "ec2:AssociateAddress",
      "ec2:CreateSecurityGroup",
      "ec2:DisassociateRouteTable",
      "ec2:DetachInternetGateway",
      "ec2:DescribeMovingAddresses",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstanceTopology",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeTags",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNatGateways",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSecurityGroupReferences",
      "ec2:DescribeNetworkInterfaceAttribute",
      "ec2:DescribeVpcs",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeManagedPrefixLists",
      "ec2:DescribeNetworkInterfacePermissions",
      "ec2:DescribeSubnets",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeRouteTables",
      "ec2:DescribeStaleSecurityGroups",
      "ec2:DescribeEgressOnlyInternetGateways",
      "ec2:DescribeVpcEndpoints",
      "iam:PassRole",
      "ssm:GetParameters",
      "ec2:ImportKeyPair",
      "ec2:DescribeKeyPairs",
      "ec2:DeleteKeyPair",
      "ec2:DescribeVolumes",
      "ec2:DescribeInstanceCreditSpecifications"
    ]
    effect    = "Allow"
    resources = ["*"]

    condition {
        test     = "StringEquals"
        variable = "ec2:Region"
        values   = [var.aws_region]
    }
  }
}

# Declare policy
resource "aws_iam_policy" "students" {
  name        = "students_policy"
  description = "students policy"
  policy      = data.aws_iam_policy_document.students.json
}

# Create an IAM group for users
resource "aws_iam_group" "students" {
  name = var.group
}

# Attach policy to group
resource "aws_iam_group_policy_attachment" "students" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.students.arn
}

# Create users
resource "aws_iam_user" "called" {
  for_each = toset(var.users)
  name     = each.key
}

# Add each user to group
resource "aws_iam_user_group_membership" "student" {
  for_each = toset(var.users)
  user     = aws_iam_user.called[each.key].name
  groups   = [aws_iam_group.students.name]
}

# Generate programmatic key for each student
resource "aws_iam_access_key" "student" {
  for_each = toset(var.users)
  user     = aws_iam_user.called[each.key].name
}

# Generate web console password for each student
resource "aws_iam_user_login_profile" "student" {
  for_each = toset(var.users)
  user     = aws_iam_user.called[each.key].name
}

# Store programmatic key in SSM with user as name and key ID as description
resource "aws_ssm_parameter" "student_secret_CLI" {
  for_each    = toset(var.users)
  name        = "${aws_iam_user.called[each.key].name}_CLI"
  value       = aws_iam_access_key.student[each.key].secret
  description = aws_iam_access_key.student[each.key].id
  type        = "SecureString"
}

# Store web console password in SSM with user as name and key ID as description
resource "aws_ssm_parameter" "student_secret_GUI" {
  for_each    = toset(var.users)
  name        = "${aws_iam_user.called[each.key].name}_GUI"
  value       = aws_iam_user_login_profile.student[each.key].password
  description = aws_iam_access_key.student[each.key].id
  type        = "SecureString"
}