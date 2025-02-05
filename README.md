# number-properties-api

Number Classifier API (AWS Lambda + API Gateway)
An AWS serverless API that classifies numbers (e.g., even, odd, prime, perfect, Armstrong) using AWS Lambda, API Gateway, and Boto3.

Table of Contents
-Overview
-Architecture
-Setup and Deployment
-API Endpoints
-Example Requests
-Troubleshooting
-License

-Overview
This project implements a publicly accessible API that classifies numbers using an AWS Lambda function triggered by API Gateway. The infrastructure is managed using Boto3 and Terraform (optional).

-Technologies Used
AWS Lambda (Serverless execution)
API Gateway (Public HTTP endpoint)
IAM Roles & Policies (Security)
AWS EC2 (Optional backend deployment)
Terraform & Boto3 (Infrastructure as Code)
Architecture
rust
Copy
Edit
User --> API Gateway --> AWS Lambda --> Response (JSON)
API Gateway receives HTTP requests.
API Gateway triggers the Lambda function.
Lambda function processes the number and returns JSON response.
Setup and Deployment

1 Prerequisites
AWS CLI configured with credentials
Python 3.8+ with boto3 installed
Terraform (optional)

2 Clone the Repository
sh
Copy
Edit
git clone https://github.com/your-repo/number-classifier.git
cd number-classifier

3 Deploy with Boto3 Script
sh
Copy
Edit
python3 task1-boto3.py
This will:
    Create the IAM Role for Lambda
    Deploy the Lambda function
    Configure API Gateway
    Generate a public API URL

4 Verify Deployment
Check the API Gateway URL in AWS Console or run:

sh
Copy
Edit
curl "https://your-api-id.execute-api.us-east-2.amazonaws.com/prod/api/classify-number?number=371"
API Endpoints

1 Classify a Number
 Endpoint:

typescript
Copy
Edit
GET /api/classify-number?number=<your_number>
 Example:

bash
Copy
Edit
https://your-api-id.execute-api.us-east-2.amazonaws.com/prod/api/classify-number?number=28
 Response:

json
Copy
Edit
{
  "number": 28,
  "is_prime": false,
  "is_even": true,
  "is_perfect": true,
  "is_armstrong": false
}

2Error Handling
Invalid input (number missing or not numeric) → 400 Bad Request
Server error → 500 Internal Server Error
Example Requests

1 Using curl
sh
Copy
Edit
curl "https://your-api-id.execute-api.us-east-2.amazonaws.com/prod/api/classify-number?number=7"

2 Using Python
python
Copy
Edit
import requests
url = "https://your-api-id.execute-api.us-east-2.amazonaws.com/prod/api/classify-number?number=7"
response = requests.get(url)
print(response.json())

Troubleshooting
Common Errors & Fixes
Error	Cause	Solution
403 Forbidden	API Gateway permissions issue	Add AWS::Lambda::Permission to allow API Gateway to invoke Lambda
400 Bad Request	Missing or invalid number parameter	Ensure you're passing a valid integer or float
Invalid value 'http' for IP protocol	Incorrect security group rule	Change "http" to "tcp" in aws_security_group
Check API Gateway Logs
sh
Copy
Edit
aws logs tail /aws/lambda/number-classifier --follow
