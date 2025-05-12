# Create a KMS key to encrypt secrets stored in AWS Secrets Manager

resource "aws_kms_key" "demo_kms_key" {
  description             = "KMS key for demo credentials rotation"
  enable_key_rotation     = true                      # Enables automatic key rotation for security
  deletion_window_in_days = 7                         # Key will be deleted 7 days after scheduling deletion
}

# Store MongoDB credentials securely in Secrets Manager

# resource "aws_secretsmanager_secret" "db_credentials" {
#   name       = "db-credentials"                 # Secret name visible in AWS Console
#   kms_key_id = aws_kms_key.demo_kms_key.key_id       # Use the KMS key to encrypt this secret
# }

# Define the DB credentials (username and password)

# resource "aws_secretsmanager_secret_version" "db_credentials_version" {
#   secret_id     = aws_secretsmanager_secret.db_credentials.id
#   secret_string = jsonencode({                        # Store values in JSON format
#     username = var.db_username,
#     password = var.db_password
#   })
# }
data "aws_secretsmanager_secret_version" "mongo_creds" {
  secret_id = "mongodb-credentials"
}


data "aws_secretsmanager_secret" "mongo_secret" {
  name = "mongodb-credentials"
}


# Store an API token securely in Secrets Manager (e.g., used by the CACS application)

resource "aws_secretsmanager_secret" "api_token" {
  name       = "cacs-api-token"
  kms_key_id = aws_kms_key.demo_kms_key.key_id       # Use the same KMS key for consistency
}

# Define the actual API token value

resource "aws_secretsmanager_secret_version" "api_token_version" {
  secret_id     = aws_secretsmanager_secret.api_token.id
  secret_string = jsonencode({
    token = var.api_token
  })
}

#####

# Step 1: IAM policy that lets EC2 access Secrets Manager secrets

resource "aws_iam_policy" "access_secrets" {
  name        = "AccessSecretsForCACS"
  description = "Allows EC2 to read secrets for the CACS app"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = [
          data.aws_secretsmanager_secret.mongo_secret.arn,
          aws_secretsmanager_secret.api_token.arn
        ]
      }
    ]
  })
}

# Step 2: IAM Role for EC2

resource "aws_iam_role" "cacs_ec2_role" {
  name = "cacs-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Step 3: Attach the secrets access policy to the EC2 role

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.cacs_ec2_role.name
  policy_arn = aws_iam_policy.access_secrets.arn
}

# Step 4: Create instance profile to connect IAM role to EC2

resource "aws_iam_instance_profile" "cacs_instance_profile" {
  name = "cacs-instance-profile"
  role = aws_iam_role.cacs_ec2_role.name
}