data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_role" "sso_admin" {
  name = "AWSReservedSSO_AWSAdministratorAccess_*"
}
