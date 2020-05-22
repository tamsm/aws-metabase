provider "aws" {}

terraform {
  backend "s3" {
    // S3 refs, No variable allowed here, Chicken or the Egg
    bucket = "data-infra-state"
    key    = "global/s3/metabase.tfstate"
    region = "eu-west-3"
//    shared_credentials_file = "~/.aws/credentials"
//    profile = "AdminView"
    // DynamoDB refs
    dynamodb_table = "infra_state"
    encrypt        = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "data-infra-state"
  region = var.aws_region
  // Enable for Revision purposes
  versioning {
    enabled = true
  }
  // Prevent accidental deletion when "terraform destroy" on all resources
  lifecycle {
    prevent_destroy = true
  }
  // AES256 on Server Side
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = var.project
  }
}

// AWS DynamoTable
resource "aws_dynamodb_table" "terraform_state_locks" {
  hash_key     = "LockID"
  name         = "infra_state"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name       = "LockID"
    type       = "S"
  }
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = var.project
  }
}
