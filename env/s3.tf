resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = var.project_name
  acl           = "private"
  force_destroy = true
}

data "archive_file" "lambda_js" {
  type = "zip"

  source_dir  = "${path.module}/../js"
  output_path = "${path.module}/js.zip"
}

resource "aws_s3_bucket_object" "lambda_js_obj" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "js.zip"
  source = data.archive_file.lambda_js.output_path

  etag = filemd5(data.archive_file.lambda_js.output_path)
}
