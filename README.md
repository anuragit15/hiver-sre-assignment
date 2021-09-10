# hiver-sre-assignment
Assignment for hiver SRE

Part1: Terraform Iac

To run the terraform configuration:

Step1: Install terraform
Step2: The Aws provider expects a configuration file saved in ~/.aws/credentials, the systax of the file is as below:

[default]
aws_access_key_id = A*************
aws_secret_access_key = D***********

Or use any other authentication method as per: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication

Step3: cd terraform-iac
Step4: terraform apply

Note: There are no input variables expected for the terraform config.

Part2: Python script

To run the Python Script:

Step1: cd python-ec2 
Step2: pip3 install -r requirements.txt
Step3: python3 describe-ec2.py