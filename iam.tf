resource "aws_iam_role" "modules" {
  name = "${local.name_prefix}-modules"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
      },
    ]
  })
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
          module.modules_store.dynamodb_table_arn,
        ],
      },
    ]
  })
}
