provider "aws" {
  region = "ap-northeast-1"
}

# IAMロールモジュール
module "describe_regions_for_ec2" {
  source     = "./iam_role"
  name       = "describe-regions-for-ec2"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.allow_describe_regions.json
}

data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeRegions"] #リージョン一覧を取得
    resources = ["*"]
  }
}

# セキュリティグループモジュール
module "default_sg" {
  source      = "./security_group"
  name        = "module_sg"
  vpc_id      = aws_vpc.default.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}
