What You’re Building
S3 bucket → stores Terraform state file
DynamoDB table → state locking (prevents conflicts)

Terraform cannot create backend and use it in same step.

👉 First create:

S3 bucket
DynamoDB table

👉 Then configure backend


##backend-setup.tf
resource "aws_s3_bucket" "backend_bucket" {
  bucket = "my-terraform-backend-bucket"


  tags = {
    Name        = "Terraform Backend Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_public_access_block" "backend_bucket_public_access_block" {
  bucket = aws_s3_bucket.backend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backend_bucket_versioning" {
  bucket = aws_s3_bucket.backend_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_bucket_encryption" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "backend_lock_table" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Production"
  }
}




terraform init
terraform apply

👉 This creates:

S3 bucket
DynamoDB table

--------------
Step 2: Configure Remote Backend
##backend.tf
terraform {
    backend "s3" {
        bucket = "my-terraform-state-bucket"
        region = "us-west-2"
        key    = "/eks/terraform.tfstate"
        dynamodb_table = "terraform-lock-table"
        encrypt = true

    }
}

🔁 Step 3: Reinitialize Terraform
terraform init


