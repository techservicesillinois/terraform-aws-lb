provider "aws" {
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::621331288878:role/CrossAccountAdmin"
  }
}
