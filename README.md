#Mayor's Number Classifier API

This project deploys a serverless API on AWS using Lambda, API Gateway, and IAM. The API classifies numbers (e.g., identifying perfect, Armstrong, or prime numbers) based on user input. The infrastructure and deployment are automated using a Python script powered by Boto3.

Features
Classify Numbers: Determine if a number is perfect, Armstrong, or prime.
Public API: Accessible over the internet via an HTTP endpoint.
Serverless Architecture: Deployed using AWS Lambda and API Gateway for scalability.
Automated Deployment: Provisioning of AWS resources (IAM, Lambda, API Gateway) with a single Python script.

Project Structure
bash
Copy
Edit
├── lambda_code/
│   └── lambda_function.py       # Lambda function logic
├── task1-boto3.py               # Deployment script using Boto3
├── README.md                    # Project documentation
└── requirements.txt             # Python dependencies

Prerequisites
AWS CLI configured with credentials
Python 3.6+ installed
Boto3 Library (pip install boto3)
AWS permissions to create IAM roles, Lambda functions, and API Gateway resources

Installation
Clone the Repository:

bash
Copy
Edit
git clone https://github.com/your-repo/number-classifier-api.git
cd number-classifier-api
Install Dependencies:

bash
Copy
Edit
pip install -r requirements.txt

Deployment Steps
Run the Deployment Script:

bash
Copy
Edit
python3 task1-boto3.py
Output:
After successful deployment, you’ll receive the public API URL similar to:

php-template
Copy
Edit
https://<api-id>.execute-api.<region>.amazonaws.com/prod/api/classify-number

API Usage
Endpoint:
typescript
Copy
Edit
GET /api/classify-number?number=<value>
Example Request:
bash
Copy
Edit
curl "https://<api-id>.execute-api.<region>.amazonaws.com/prod/api/classify-number?number=371"
Sample Response:
json
Copy
Edit
{
  "number": 371,
  "is_armstrong": true,
  "is_perfect": false,
  "is_prime": false
}

Error Handling:
Invalid Input:
json
Copy
Edit
{
  "error": "Invalid input. Please provide a valid number."
}

HTTP Status Codes:
200 OK → For valid requests
400 Bad Request → For invalid inputs

Security Configuration
IAM Role: Grants Lambda permission to execute
API Gateway: Configured to allow public access
Lambda Permissions: Adjusted using Boto3 to integrate securely with API Gateway

Troubleshooting
403 Errors: Ensure the Lambda function has the correct resource-based policy to allow API Gateway invocation.
Connection Issues: Verify that the API Gateway is deployed and the endpoint is enabled for public access.
Timeouts: Check Lambda's timeout settings and API Gateway resource configuration.
