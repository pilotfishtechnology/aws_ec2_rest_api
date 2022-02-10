resource "aws_lambda_function" "app" {
  function_name = "${var.project_name}-app"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_js_obj.key

  runtime = "nodejs12.x"
  handler = "lambda_function.handler"

  source_code_hash = data.archive_file.lambda_js.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.app.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "ec2-policy-document" {
  statement {
    sid       = ""
    actions   = ["ec2:StartInstances", "ec2:StopInstances"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "ec2-policy" {
  name        = "${var.project_name}-ec2-policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.ec2-policy-document.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-pipeline-attachment" {
  policy_arn = aws_iam_policy.ec2-policy.arn
  role       = aws_iam_role.lambda_exec.name
}
