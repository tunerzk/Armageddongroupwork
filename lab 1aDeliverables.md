Student Deliverables:

Screenshot of: RDS SG inbound rule using source = sg-ec2-lab EC2 role attached /list output showing at least 3 notes
<img width="1630" height="661" alt="image" src="https://github.com/user-attachments/assets/38822652-e13e-4c12-8a80-6077bb04b6ab" />
<img width="1566" height="686" alt="image" src="https://github.com/user-attachments/assets/0b831639-821e-4c88-a263-eaf57d1e5b18" />
![Screenshot 2026-01-04 151442](https://github.com/user-attachments/assets/f68395df-f3d9-4176-848f-4a35282a1276)
![Screenshot 2026-01-12 194313](https://github.com/user-attachments/assets/e5bc3595-c887-4104-a034-f3db8e36faa3)






Short answers: A) Why is DB inbound source restricted to the EC2 security group? The DB is restricted to the EC2 in order to provide direct secure access into the database.


B) What port does MySQL use? Port 3306



C) Why is Secrets Manager better than storing creds in code/user-data? The secrets manager is better because it compartmentalizes the info which is more secured. If all data was store in one location, than a breach
into that location would cause a wider spand "blast radius" of damage.


Evidence for Audits / Labs (Recommended Output)

aws ec2 describe-security-groups --group-ids sg-0123456789abcdef0 > sg.json aws rds describe-db-instances --db-instance-identifier mydb01 > rds.json aws secretsmanager describe-secret --secret-id my-db-secret > secret.json aws ec2 describe-instances --instance-ids i-0123456789abcdef0 > instance.json aws iam list-attached-role-policies --role-name MyEC2Role > role-policies.json

Then Answer: Why each rule exists? Each rule exist to minumize access 
What would break if removed? If removed that would break access to the database
Why broader access is forbidden? Broader access will give less security control over information on the database
Why this role exists? The role gives access to the correct services needed for the Infastructure to work properly
Why it can read this secret? It can read the secrete because it was placed into the policy giving the apps access to the info within the secret
Why it cannot read others? It can not read others because the policy for access has not be given to the app or ec2



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
3. Name the security group ( (sg-ec2-lab) for the EC2 do not create a security group for the database yet

EC2
1. Create EC2 by lauching a instance in the aws console
2. Create name for instance
3. Select AMI of T.3micro  amazon linux
4. Choose or create a new key pair-needed to SSH into the EC2
5. Select the same VPC that was created in the first step
6. Select the public subnet in us-west-2a
7. Select the security group that was named SG-EC2-LAB
8. Insert user data script and make neccessary changes for region, also include install (dnf install mariadb105 -y) into the top half of the script then create instance

Policy & Roles
1. The EC2 will require a policy to allow information to be retrieved from the database
2. Creat a Role first by going to IAM create roles, select trusted entities as EC2
3. Allow for the EC2 to read the secret that will be created in the secret manager later
   <img width="1532" height="322" alt="image" src="https://github.com/user-attachments/assets/278b94a9-ec2d-4742-94b5-23fdeb76fce5" />
   <img width="1827" height="623" alt="image" src="https://github.com/user-attachments/assets/e13a58f4-0f60-44cb-bc4d-1d9697f9448c" />
4. Create a permission policy which will merge into the role and become a "inline policy"
5. Make the necessary changes for <REGION> and <ACCOUNT_ID>, also take note of the (lab/rds/mysql) as this needs to be the exact secrets name in Secrets Manager.
<img width="1888" height="530" alt="image" src="https://github.com/user-attachments/assets/673565f2-e3b2-4faa-aaf8-bfa5a145b05f" />

7. Attach role to EC2: EC2 → Instance → Actions → Security → Modify IAM role → select your role

RDS Database
1. Create database in RDS AND AURORA and select full configuration
2. Select MYSQL and use free tier
  ![Screenshot 2026-01-04 151544](https://github.com/user-attachments/assets/97088c11-028d-4a2e-840c-e4c068759d46)
 4. Select single AZ instance deployment
5. Create name for DB-IDENTIFIER (lab-mysql)
6. Create name and password to secure database accesss / name= (admin) create personal password (xxxxxxxx) in credentials manager section
7. Move to connectivity section
8. In connectivity select connect to compute resources
9. Select the EC2 that was created
10. The VPC will be automatically selected
11. DB SUBNET GROUP should be automatically setup make sure to select same AZ that the EC2 is located which is us-west-2a
12. The database subnets should be private select publc access=NO
13. Select setup new security groups for RDS and name (sg-rds-lab) This will only allow port 3306 but will create 2 security groups one in EC2 and one in DB
14. Enable logs and checks
15. Create database
![Screenshot 2026-01-04 152702](https://github.com/user-attachments/assets/a805cc69-7e5d-48f5-9430-7398dcaebc8d)

** Return back to the RDS security group and change the inbound rules to Set Source = sg-ec2-lab for TCP 3306.
Secret Manager
1. Create secret manager (store DB creds)
2. Select store new secret
3. Secret type: Credentials for RDS database
4. Create user (admin) and password
5. Select your RDS instance lab-mysql
6. Create Secret name: lab/rds/mysql
![Screenshot 2026-01-04 153741](https://github.com/user-attachments/assets/aa19cf40-a487-4692-8089-6af035928a3f)

Return to EC2 instance once database has configured and select "Connect" to SSH into the instance
![Screenshot 2026-01-04 153855](https://github.com/user-attachments/assets/59149ea0-bb84-4a01-822d-70755ffba446)
![Screenshot 2026-01-04 154303](https://github.com/user-attachments/assets/6b214af1-bbd5-4d03-a4d4-5bab8c055365)

In the EC2 CLI run command (aws secretmanager get-secret-value --secret-id lab/rds/mysql) confirm user name and password
![Screenshot 2026-01-04 154511](https://github.com/user-attachments/assets/c906507a-a594-470c-ac9d-ea879cf48c1f)

In the EC2 CLI run command ( mysql -h 
![Screenshot 2026-01-04 172345](https://github.com/user-attachments/assets/70ed0ee5-82c7-41d0-a1e9-ee7af33ac96b)
This logs you into the database instance 
Enter show databases;  this will display the names of files within 
![Screenshot 2026-01-05 111852](https://github.com/user-attachments/assets/37389632-2fa4-450e-8568-e5561f27aa4a)
To add a file to the database enter Create database; use file name (labdb)
![Screenshot 2026-01-05 112106](https://github.com/user-attachments/assets/317c1d03-a53a-4e84-83cb-76e7fe8ab52d)
Verify that new file was created show databases;
![Screenshot 2026-01-05 112155](https://github.com/user-attachments/assets/d7d0c0d3-0ddd-4ba2-8b89-0b0b3db9058d)
Enter (exit) to leave database, then copy public IP of the EC22 and paste it into the search bar
![Screenshot 2026-01-04 151442](https://github.com/user-attachments/assets/d45aefc9-d647-4b1d-ac0e-6a8b9dd6ad78)
Then run IP address/init to initialize db note
![Screenshot 2026-01-12 191557](https://github.com/user-attachments/assets/87805740-d11c-4950-b8c8-b862e99e1029)
Add notes to the database file labdb
![Screenshot 2026-01-12 194313](https://github.com/user-attachments/assets/efb517cb-ff47-468b-9a82-7ad17143e67f)

























   
