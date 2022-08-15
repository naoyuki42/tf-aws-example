resource "aws_kms_key" "default" {
  description             = "Default Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "default" {
  name          = "alias/default"
  target_key_id = aws_kms_key.default.key_id
}
