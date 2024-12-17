provider "aws" {
  region     = "ap-southeast-1"
  access_key = "S3xxxxxxxxxxxxxxx"
  secret_key = "S3xxxxxxxxxxxxxxx"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "aomlnwza007191144zs456zs"

  tags = {
    Name        = "aomLnwZa007191144zs456zs"
    Environment = "Sandbox"
  }

  versioning {
    enabled = false
  }


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256" #  use SSE-S3 (AES256)
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "my_bucket_block_public_access" {
  bucket = aws_s3_bucket.my_bucket.bucket

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
}


# resource "aws_s3_bucket_policy" "my_bucket_policy" {
#   bucket = aws_s3_bucket.my_bucket.bucket

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "s3:GetObject"
#         Effect    = "Allow"
#         Resource  = "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/*"
#         Principal = "*"
#       }
#     ]
#   })
# }

output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
