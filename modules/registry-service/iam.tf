resource "aws_iam_role" "modules" {
  name = "${local.name_prefix}-modules"

  assume_role_policy = jsonencode(local.api_gateway_assume_policy)
}

resource "aws_iam_role_policy" "modules" {
  role = aws_iam_role.modules.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:GetRecords",
          "dynamodb:Scan",
        ]
        Resource = [
          var.dynamodb_table_arn
        ],
      },
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
        ]
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "auth" {
  count = length(local.authorizers)

  name               = "${local.name_prefix}-authorizer"
  assume_role_policy = jsonencode(local.api_gateway_assume_policy)
}

resource "aws_iam_role_policy" "auth" {
  count = length(local.authorizers)

  role = aws_iam_role.auth[count.index].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = data.aws_lambda_function.auth[count.index].arn,
      },
    ]
  })
}
