Mayor's Number Properties API
A simple REST API that returns mathematical properties and fun facts about numbers. The project is deployed on AWS using Terraform for infrastructure as code (IaC) and Python (Flask) for the API.

🛠️ Tech Stack
Python (Flask) - API implementation
Terraform - Infrastructure as Code (IaC)
AWS - Cloud hosting (EC2, IAM, S3, etc.)
📌 Features
Retrieve properties like prime, even/odd, Fibonacci, and factorial for any number
Supports CORS for cross-origin requests
Deployed using Systemd for process management
📁 Project Structure
bash
Copy
Edit
/number-properties-api
│── terraform/                   # Terraform configurations for AWS infrastructure
│── app/                          # Python API source code
│   ├── app.py                    # Main Flask application
│   ├── requirements.txt           # Python dependencies
│   ├── config.py                  # Configuration settings
│   ├── services/                  # Logic for number properties
│   ├── .venv/                     # Python virtual environment (excluded from repo)
│── README.md                       # Project documentation
│── api.service                     # Systemd service definition
│── main.tf                         # Terraform main configuration

🚀 Getting Started
1️⃣ Prerequisites
Python 3.7+ installed
Terraform installed
AWS CLI configured (aws configure)
An AWS IAM user with EC2 & S3 permissions

2️⃣ Clone the Repository
bash
Copy
Edit
git clone https://github.com/mayorpasca32/number-properties-api.git
cd number-properties-api

3️⃣ Deploy Infrastructure with Terraform
Navigate to the Terraform directory:

bash
Copy
Edit
cd terraform
terraform init
terraform apply -auto-approve
Terraform will: ✅ Create an EC2 instance for the API
✅ Set up IAM roles and security groups
✅ Provision an S3 bucket (if needed)

4️⃣ Deploy the API
SSH into the EC2 instance and set up the API:

bash
Copy
Edit
ssh -i your-key.pem ec2-user@your-ec2-instance
🔹 Install Dependencies
bash
Copy
Edit
sudo yum install -y python3 python3-venv
cd /app
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
🔹 Start the API
bash
Copy
Edit
python app.py
The API should now be running at http://localhost:5000

5️⃣ Set Up Systemd for Auto-Restart
To run the API as a system service:

bash
Copy
Edit
sudo cp api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable api.service
sudo systemctl start api.service
Check status:

bash
Copy
Edit
sudo systemctl status api.service
🔄 API Endpoints
GET /api/number/{n}
Retrieve number properties
📌 Example:

bash
Copy
Edit
curl http://your-api-url/api/number/7
📌 Response:

json
Copy
Edit
{
  "number": 7,
  "is_prime": true,
  "is_fibonacci": false,
  "factorial": 5040
}
🛠️ Troubleshooting
1️⃣ Check API Logs
bash
Copy
Edit
journalctl -u api.service -n 50 --no-pager
2️⃣ Restart the Service
bash
Copy
Edit
sudo systemctl restart api.service
