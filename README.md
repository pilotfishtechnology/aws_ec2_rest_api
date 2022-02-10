## Requirement:

Stop & Start EC2 instances with a rest service.

## Technologies used in this project:

Terraform

AWS Lambda

AWS API gateway

AWS S3 Bucket

## Take Note:

Before starting the deployment please make sure the correct variables are set within the terraform script (have a look at the env/variables.tf script). Also, set the correct EC2 ID’s in the Lambda Script (have a look at the ec2Instances variable in the js/lambda_function.js script)

## Commands to deploy:
```bash
cd env
terraform init
terraform plan
terraform apply
```

## Command to Invoke Lambda:
```bash
aws lambda invoke --region=us-east-1 --function-name=$(terraform output -raw function_name) response.json
```

## Command to Invoke API to Start Instance:
```bash
curl "$(terraform output -raw base_url)/request?token=123&id=i-123&action=start"
```

## Command to Invoke API to Stop Instance:
```bash
curl "$(terraform output -raw base_url)/request?token=123&id=i-123&action=stop"
```
