# hiver-sre-assignment

## Part 1: Terraform Iac

To run the terraform configuration:

##### Step 1: Install terraform

##### Step 2: The Aws provider expects a configuration file saved in ~/.aws/credentials, the syntax of the file is as below:
```
[default]
aws_access_key_id = A*************
aws_secret_access_key = D***********
```

Or use any other authentication method as per: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication

##### Step 3: cd terraform-iac

##### Step 4: terraform apply

Note: There are no input variables expected for the terraform config.


## Part 2: Python script

To run the Python Script:

##### Step 1: `cd python-ec2`

##### Step 2: `pip3 install -r requirements.txt`

##### Step 3: `python3 describe-ec2.py`
