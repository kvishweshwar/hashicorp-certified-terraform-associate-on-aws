resource "aws_s3_bucket" "my-bucket" {
  bucket        = var.bucket_name
  force_destroy = true
  tags = merge(
    var.bucket_tags,
    {
      name = var.bucket_name
      region = var.aws_region
    }
  )
}

/*
resource "aws_s3_bucket_policy" "my-bucket-policy-config" {
  bucket = aws_s3_bucket.my-bucket.id

  policy = <<EOF
{
  "Id": "Policy1706616070924",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1706616069266",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Principal": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_policy" "my-bucket-policy-config" {
  bucket = aws_s3_bucket.my-bucket.id
  policy = file("bucket-policy.json")
}
*/

resource "aws_s3_bucket_policy" "my-bucket-policy-config" {
  bucket = aws_s3_bucket.my-bucket.id
  policy = data.aws_iam_policy_document.bucket-policy.json
}

resource "aws_s3_bucket_ownership_controls" "my-bucket-ownership-config" {
  bucket = aws_s3_bucket.my-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my-bucket-public-access-config" {
  bucket = aws_s3_bucket.my-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "my-bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my-bucket-ownership-config,
    aws_s3_bucket_public_access_block.my-bucket-public-access-config,
  ]

  bucket = aws_s3_bucket.my-bucket.id
  acl    = "public-read"
}


resource "aws_s3_bucket_versioning" "my-bucket-versioning-config" {
  bucket = aws_s3_bucket.my-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "my-bucket-website-config" {
  bucket = aws_s3_bucket.my-bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
  routing_rule {
    condition {
      key_prefix_equals = "/"
    }
    redirect {
      replace_key_prefix_with = "/index.html"
    }
  }
}

resource "time_sleep" "time-sleep" {
  depends_on      = [aws_s3_bucket.my-bucket]
  create_duration = "60s"
}

resource "null_resource" "null-resource" {
  depends_on = [time_sleep.time-sleep]
  triggers = {
    always-update = timestamp()
  }
  provisioner "local-exec" {
    working_dir = "./"
    command     = "aws s3 cp ${var.index_file} s3://${var.bucket_name}"
  }
}




