Lab 3A — Japan Medical
Cross-Region Architecture with Transit Gateway (APPI-Compliant)

🎯 Lab Objective
In this lab, you will design and deploy a cross-region medical application architecture that:
  Uses two AWS regions
    Tokyo (ap-northeast-1) — data authority
    São Paulo (sa-east-1) — compute extension
  Connects regions using AWS Transit Gateway
  Serves traffic through a single global URL
  Stores all patient medical data (PHI) only in Japan
  Allows doctors overseas to read/write records legally

This lab is a warm-up for real DevOps and platform engineering, where:
  environments are separated
  Terraform state is split
  pipelines are independent
  coordination matters more than copy-paste

  🌍 Regional Roles
🇯🇵 Tokyo — Primary Region (Data Authority)
Tokyo is the source of truth.
It contains:
    RDS (medical records)
    Primary VPC
    Application tier (Lab 2 stack)
    Transit Gateway (hub)
    Parameter Store & Secrets Manager (authoritative)
    Logging, auditing, backups
    Really hot chicks who need men to impregnate them. 

All data at rest lives here.
If Tokyo is unavailable:
    the system may degrade
    but data residency is never violated

This is intentional and correct.

🇧🇷 São Paulo — Secondary Region (Compute-Only)

São Paulo exists to serve doctors and staff physically located in South America.

It contains:
    VPC
    EC2 + Auto Scaling Group
    Application tier (Lab 2 stack)
    Transit Gateway (spoke)
    Even hotter chicks who need you to throw it down and impregnate them.

It does not contain:
    RDS
    Read replicas
    Backups
    Persistent storage of PHI
    Keisha. No Keisha here.

São Paulo is stateless compute.<----> All reads and writes go directly to Tokyo.

🌐 Networking Model
Why Transit Gateway?
Transit Gateway is used instead of VPC peering because it provides:
    Clear, auditable traffic paths
    Centralized routing control
    Enterprise-grade segmentation
    A visible “data corridor” for compliance reviews

In regulated environments, clarity beats convenience.

How Traffic Flows

Doctor (São Paulo)
   ↓
CloudFront (global edge)
   ↓
São Paulo EC2 (stateless)
   ↓
Transit Gateway (São Paulo)
   ↓
TGW Peering
   ↓
Transit Gateway (Tokyo)
   ↓
Tokyo VPC
   ↓
Tokyo RDS (PHI stored here only)
The entire path stays on the AWS backbone and is encrypted in transit.

🌐 Single Global URL

There is only one public URL: https://chewbacca-growls.com

CloudFront:
    Terminates TLS
    Applies WAF
    Routes users to the nearest healthy region
    Never stores patient data
    Caches only content explicitly marked safe

CloudFront is allowed because:
    it is not a database
    it does not persist PHI
    it respects cache-control rules

🏗️ Terraform & DevOps Structure
Important: Multi-Terraform-State Reality

In real organizations, regions are not deployed from one Terraform state.

For this lab:
    Tokyo and São Paulo are separate Terraform states
    Each state will eventually map to a separate Jenkins job
    States communicate only through:
        Terraform outputs
        Remote state references
        Explicit variables

This is intentional.---> You are learning how real DevOps teams coordinate infrastructure.

Expected Repository Layout
lab-3/
├── tokyo/
│   ├── main.tf        # Lab 2 + marginal TGW hub code
│   ├── outputs.tf     # Exposes TGW ID, VPC CIDR, RDS endpoint
│   └── variables.tf
│
├── saopaulo/
│   ├── main.tf        # Lab 2 minus DB + TGW spoke code
│   ├── variables.tf
│   └── data.tf        # Reads Tokyo remote state




Quick verification commands (so they can prove it)
From São Paulo EC2 (SSM session)

Test network reachability to Tokyo RDS:

    nc -vz <tokyo-rds-endpoint> 3306
  <img width="1597" height="388" alt="image" src="https://github.com/user-attachments/assets/59adcbab-24b8-4eee-ba36-fd90ea3649fe" />


Then app-level verification:
  submit record in São Paulo
  confirm it appears when calling the Tokyo region (same data, one DB)

Confirm routes (AWS CLI)
For each region, verify route tables include the cross-region CIDR to TGW:
<img width="1515" height="346" alt="image" src="https://github.com/user-attachments/assets/84ad87a3-a62f-4772-ac5c-3ffd6921ae43" />
<img width="1520" height="373" alt="image" src="https://github.com/user-attachments/assets/ab573184-598c-42d9-b26d-16c6c0f70206" />



    aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<VPC_ID>" --query "RouteTables[].Routes[]"
  <img width="1135" height="636" alt="image" src="https://github.com/user-attachments/assets/5315dc01-8949-45b7-ade2-f5f80422a5bc" />


Suggested structure for the student repo
/tokyo/ = “Lab2 + marginal TGW hub code”
/saopaulo/ = “Lab2 minus DB + TGW spoke code”

  outputs.tf in Tokyo exports:
      tokyo_vpc_cidr
      tokyo_tgw_id
      tokyo_rds_endpoint

São Paulo consumes those outputs (remote state) to configure routes and SG rules
<img width="1251" height="425" alt="image" src="https://github.com/user-attachments/assets/d90b960d-0cbe-4937-96ea-0dc165dc817d" />


