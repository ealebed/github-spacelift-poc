resource "aws_s3_bucket" "demo" {
  bucket = "tf-demo-${var.project_name}-${var.environment}-531438381462"
}

resource "aws_instance" "demo" {
  ami           = "ami-0c1bc246476a5572b" # pick a valid AMI for eu-west-1
  instance_type = "t3.micro"

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}
