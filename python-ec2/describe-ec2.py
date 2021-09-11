import boto3
from prettytable import PrettyTable

session = boto3.session.Session()

ec2_client = session.client(service_name = 'ec2', region_name = "us-east-1")

def get_tags(resourceId):
    tags = ec2_client.describe_tags(Filters=[
        {
            "Name": "resource-id",
            "Values": [resourceId]
        },
        {
            "Name": "resource-type",
            "Values": ["instance"]
        }
    ])
    for f in tags['Tags']:
        if f['Key'] == 'Name':
            return f['Value']
            break
        else:
            continue

reservations = ec2_client.describe_instances(Filters=[
        {
            "Name": "instance-state-name",
            "Values": ["running"]
        }
    ]).get("Reservations")

table = PrettyTable(['Name Tag','Instance ID'])

for reservation in reservations:
    for instance in reservation["Instances"]:
        if instance["InstanceType"] == 'm5.xlarge':
          instance_id = instance["InstanceId"]
          name_tag = get_tags(instance_id)
          table.add_row([ name_tag , instance_id ])

print(table)
