Student Deliverables:

Screenshot of: RDS SG inbound rule using source = sg-ec2-lab EC2 role attached /list output showing at least 3 notes
<img width="1630" height="661" alt="image" src="https://github.com/user-attachments/assets/38822652-e13e-4c12-8a80-6077bb04b6ab" />
<img width="1566" height="686" alt="image" src="https://github.com/user-attachments/assets/0b831639-821e-4c88-a263-eaf57d1e5b18" />
![Screenshot 2026-01-04 151442](https://github.com/user-attachments/assets/f68395df-f3d9-4176-848f-4a35282a1276)
![Screenshot 2026-01-12 194313](https://github.com/user-attachments/assets/e5bc3595-c887-4104-a034-f3db8e36faa3)






Short answers: A) Why is DB inbound source restricted to the EC2 security group?


B) What port does MySQL use? Port 3306



C) Why is Secrets Manager better than storing creds in code/user-data?


Evidence for Audits / Labs (Recommended Output)

aws ec2 describe-security-groups --group-ids sg-0123456789abcdef0 > sg.json aws rds describe-db-instances --db-instance-identifier mydb01 > rds.json aws secretsmanager describe-secret --secret-id my-db-secret > secret.json aws ec2 describe-instances --instance-ids i-0123456789abcdef0 > instance.json aws iam list-attached-role-policies --role-name MyEC2Role > role-policies.json

Then Answer: Why each rule exists?
What would break if removed?
Why broader access is forbidden?
Why this role exists?
Why it can read this secret?
Why it cannot read others?



Steps:

VPC

1. Create a VPC that will house the EC2, and Security group that will connect to the RDS database
2.  Choose VPC and more and select CIDR, I am using (10.63.0.0/16) in us-west-2
3.  Select AZ'S that will have two private and public subnets (required by the RDS) Set the CIDR blocks for the subnets
4.  Enable HOST DNS NAME and DNS RESOLUTION
5.  Do not include S3 OR Endpoint

Security Groups
1. Create a security group for the EC2, this will secure the Ec2 and connect to the RDS instance
2. Use port 80 HTTP 0.0.0.0/0 AND port 22 SSH in order to ssh into the EC2 use your IP for security purposes
3. Name the security group ( (sg-ec2-lab)
   
