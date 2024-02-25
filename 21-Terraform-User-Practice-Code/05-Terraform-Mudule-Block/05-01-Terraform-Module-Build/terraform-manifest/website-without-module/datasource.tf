data "aws_iam_policy_document" "bucket-policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}