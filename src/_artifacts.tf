resource "massdriver_artifact" "bucket" {
  field                = "bucket"
  provider_resource_id = aws_s3_bucket.main.arn
  name                 = "AWS S3 Bucket: ${aws_s3_bucket.main.arn}"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          arn = aws_s3_bucket.main.arn
        }
        security = {
          iam = {
            read = {
              policy_arn = aws_iam_policy.read.arn
            }
            write = {
              policy_arn = aws_iam_policy.write.arn
            }
          }
        }
      }
      specs = {
        aws = {
          region = var.bucket.region
        }
      }
    }
  )
}
