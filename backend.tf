terraform {
    backend "s3" {
        bucket = "my-terraform-state-bucket"
        key    = "eks/terraform.tfstate"
        region = "us-east-2"
        dynamodb_table = "terraform-lock-table"
        encrypt = true

    }
}