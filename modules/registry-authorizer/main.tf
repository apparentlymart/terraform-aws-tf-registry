
locals {
  function_name = "${var.name_prefix}-authorizer"
}

# --------------------------------------------------------
# Lambda Role
# --------------------------------------------------------

resource "aws_iam_role" "authorizer" {
  name               = "lambda-lambdaRole-waf"
  assume_role_policy = data.aws_iam_policy_document.authorizer_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  inline_policy {
    name   = "authorizer"
    policy = data.aws_iam_policy_document.authorizer.json
  }
}

data "aws_iam_policy_document" "authorizer" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:Describe*",
      "secretsmanager:Get*",
      "secretsmanager:List*",
    ]
    resources = [var.secret_key_arn]
  }
}

data "aws_iam_policy_document" "authorizer_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


# --------------------------------------------------------
# Lambda Archive
# --------------------------------------------------------


data "external" "lambda_archive" {
  program = ["python", "${path.module}/scripts/build_lambda.py"]
  query = {
    src_dir              = "${path.module}/authorizer"
    output_path          = "${path.module}/authorizer_package.zip"
    install_dependencies = true
  }
}

# --------------------------------------------------------
# Lambda
# --------------------------------------------------------

resource "aws_lambda_function" "authorizer" {
  function_name    = local.function_name
  filename         = data.external.lambda_archive.result.archive
  source_code_hash = data.external.lambda_archive.result.base64sha256

  role        = aws_iam_role.authorizer.arn
  runtime     = "python3.9"
  handler     = "authorizer.lambda_handler"
  timeout     = 10
  memory_size = 128
  tags        = merge(var.tags, { Name : local.function_name })
  environment {
    variables = {
      SECRET_KEY_NAME = var.secret_key_name
    }
  }
}
