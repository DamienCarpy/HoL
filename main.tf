# Définition du fournisseur AWS
provider "aws" {
  region = var.aws_region
}

# Récupération de la session utilisateur
data "aws_caller_identity" "current" {}

# Définition de la politique
data "aws_iam_policy_document" "students" {
  statement {
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeManagedPrefixLists",
      "ec2:DescribeMovingAddresses",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaceAttribute",
      "ec2:DescribeNetworkInterfacePermissions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroupReferences",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeStaleSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
      "ec2:DescribeInstances",
      "ec2:CreateVpc",
      "ec2:DeleteVpc", 
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteteSubnet",
      "ec2:CreateRouteTable", 
      "ec2:AssociateRouteTable", 
      "ec2:DeleteRouteTable",
      "ec2:CreateRoute", 
      "ec2:ReplaceRoute",
      "ec2:DeleteRoute",
      "ec2:CreateInternetGateway", 
      "ec2:AttachInternetGateway", 
      "ec2:DeleteInternetGateway",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:ModifySecurityGroupRules",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:ModifyInstanceAttribute",
      "ec2:AssociateAddress"
      ]
    effect    = "Allow"
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.id}:*"]

    condition {
        test     = "StringEquals"
        variable = "aws:RequestedRegion"
        values   = [var.aws_region]
    }
  }
}

# Déclaration de la politique
resource "aws_iam_policy" "students" {
  name        = "students_policy"
  description = "students policy"
  policy      = data.aws_iam_policy_document.students.json
}

# Création d'un groupe IAM pour les utilisateurs
resource "aws_iam_group" "students" {
  name = "students"
}

# Attachement de la politique au groupe
resource "aws_iam_group_policy_attachment" "students" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.students.arn
}

# Création des utilisateurs
resource "aws_iam_user" "called" {
  for_each = toset(var.users)
  name     = each.key
}

resource "aws_iam_user_group_membership" "student" {
  for_each = toset(var.users)
  user     = aws_iam_user.called[each.key].name
  groups   = [aws_iam_group.students.name]
}

resource "aws_iam_access_key" "student" {
  for_each = toset(var.users)
  user     = aws_iam_user.called[each.key].name
}

resource "aws_iam_user_login_profile" "student" {
  for_each = toset(var.users)
  user     = aws_iam_user.called[each.key].name
}

resource "aws_ssm_parameter" "student_secret_CLI" {
  for_each    = toset(var.users)
  name        = "${aws_iam_user.called[each.key].name}_CLI"
  value       = aws_iam_access_key.student[each.key].secret
  description = aws_iam_access_key.student[each.key].id
  type        = "SecureString"
}

resource "aws_ssm_parameter" "student_secret_GUI" {
  for_each    = toset(var.users)
  name        = "${aws_iam_user.called[each.key].name}_GUI"
  value       = aws_iam_user_login_profile.student[each.key].password
  description = aws_iam_access_key.student[each.key].id
  type        = "SecureString"
}