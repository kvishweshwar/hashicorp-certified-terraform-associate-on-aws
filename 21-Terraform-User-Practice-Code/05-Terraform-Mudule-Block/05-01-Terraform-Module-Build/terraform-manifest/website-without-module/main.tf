resource "aws_s3_bucket" "my-bucket" {
  bucket        = var.bucket_name
  force_destroy = true
  tags = {
    name = var.bucket_name
  }
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

resource "aws_s3_bucket_acl" "my-bucket-acl-config" {
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
}





