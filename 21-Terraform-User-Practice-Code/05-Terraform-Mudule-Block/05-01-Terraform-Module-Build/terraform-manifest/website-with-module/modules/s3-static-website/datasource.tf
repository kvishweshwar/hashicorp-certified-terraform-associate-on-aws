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

data "aws_iam_policy_document" "state-machine-policy" {
  
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["${aws_lambda_function.[[myFunction]].arn}:*"]
    
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}