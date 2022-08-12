variable "name" {}
variable "policy" {}
variable "identifier" {}

# IAMロール
resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }
}

# IAMポリシー
resource "aws_iam_policy" "default" {
  name   = "default"
  policy = var.policy
}

# IAMロールとIAMポリシーの紐づけ
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}
