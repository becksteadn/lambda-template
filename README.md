# lambda-template

A GitHub template for writing and uploading a Python Lambda function with Terraform.

Just run `terraform update` to build the zip file and create the function in AWS.

The function runs every 5 minutes using a scheduled CloudWatch event.