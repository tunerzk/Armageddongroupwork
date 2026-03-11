Deliverables (Students must submit)
Deliverable A — “Audit Evidence Pack” (one folder)

学生は audit-pack/ フォルダを提出。

audit-pack/
├── 00_architecture-summary.md
├── 01_data-residency-proof.txt
├── 02_edge-proof-cloudfront.txt
├── 03_waf-proof.txt
├── 04_cloudtrail-change-proof.txt
├── 05_network-corridor-proof.txt
└── evidence.json   (Malgus scripts output)

# Architecture Summary

## Overview
This system is designed as a multi‑region, APPI‑compliant architecture where all personal data remains strictly inside Japan (Tokyo region). The São Paulo region hosts only stateless application components to provide global performance and resilience without storing or processing regulated data outside Japan.

## Regional Roles
- **Tokyo (ap-northeast-1)**  
  - Primary region  
  - Hosts the RDS database containing all personal data  
  - Runs an EC2 Auto Scaling Group behind an Application Load Balancer  
  - Acts as the authoritative data region for all regulated workloads  

- **São Paulo (sa-east-1)**  
  - Secondary region  
  - Hosts only stateless EC2 application servers behind an ALB  
  - No RDS, no personal data, no persistent storage  
  - Used for latency improvements and failover capacity  

## Networking
- Each region has its own VPC with public and private subnets.  
- A **Transit Gateway corridor** connects Tokyo ↔ São Paulo, allowing controlled, auditable cross‑region traffic.  
- Route tables ensure that only application‑tier traffic flows cross‑region; database traffic never leaves Tokyo.

## Edge & Security
- **CloudFront** sits in front of both regional ALBs to provide global caching and edge termination.  
- **AWS WAF** is attached to CloudFront to block malicious traffic before it reaches either region.  
- **CloudTrail** records all management events for 90 days, ensuring full auditability of configuration changes.  
- Logs (CloudFront, WAF, etc.) are stored in the S3 bucket `Class_Lab3` under the prefix `Chwebacca-logs/`.

## Application Tier
- Both regions run identical EC2 Auto Scaling Groups.  
- Instances bootstrap via user‑data, install Apache, and expose a `/health` endpoint for ALB checks.  
- São Paulo and Tokyo ALBs each perform health checks and route traffic only to healthy instances.

## Data Residency Guarantee
- Only Tokyo contains an RDS instance.  
- São Paulo contains no data stores, ensuring APPI compliance and preventing cross‑border data transfer.


Deliverable B — One paragraph “auditor narrative”
“この設計が APPI 的に安全で、なぜ DB を海外に置けないか”を 8〜12 行で説明。


Verification Commands (CLI proof students can paste)
1) Data residency proof (RDS only in Tokyo)

    Tokyo: RDS exists

            aws rds describe-db-instances --region ap-northeast-1 \
          --query "DBInstances[].{DB:DBInstanceIdentifier,AZ:AvailabilityZone,Region:'ap-northeast-1',Endpoint:Endpoint.Address}"
   <img width="1523" height="448" alt="image" src="https://github.com/user-attachments/assets/2804a224-159a-4256-826f-f52eceec3764" />


    São Paulo: No RDS

            aws rds describe-db-instances --region sa-east-1 \
          --query "DBInstances[].DBInstanceIdentifier"
   <img width="1460" height="427" alt="image" src="https://github.com/user-attachments/assets/ce61603f-1868-42f5-80ab-74830e0ddafc" />



3) Edge proof (CloudFront logs show cache + access)
    Students capture request headers:

        curl -I https://chewbacca-growls.com/api/public-feed
   <img width="1142" height="256" alt="image" src="https://github.com/user-attachments/assets/3f48f665-5ccc-43b6-a9c8-38aa671f7867" />
   <img width="1211" height="288" alt="image" src="https://github.com/user-attachments/assets/a4d6a5f2-5ee9-45c1-84c6-5a59515bbba1" />
   <img width="1341" height="208" alt="image" src="https://github.com/user-attachments/assets/61eb3ff6-b78c-4ca5-b2e1-cdfb4b627f4a" />




And/or submit CloudFront standard log evidence (Hit/Miss/RefreshHit)
<img width="861" height="551" alt="image" src="https://github.com/user-attachments/assets/e103f464-00e2-4443-b7cb-814ea72932b8" />


3) WAF proof

Provide:
        WAF log snippet or Insights summary
        WAF logging destination options are documented 
        <img width="1427" height="275" alt="image" src="https://github.com/user-attachments/assets/0d718096-f81f-4d04-b469-f33a075fa065" />
        WAF IS BLOCKING ATTACKS SQLI
        <img width="867" height="577" alt="image" src="https://github.com/user-attachments/assets/63a84966-3f9b-40c7-9060-13ea8a8f59b4" />
        Summary:
        🛡️ AWS WAF Security Report
Protected Asset: CloudFront Distribution E491HUUSS0F8D  
Domain: armadawgs-growl.click  
WAF Scope: Global (CloudFront)
Date Range: Last 24 Hours
Prepared For: Security Review / Audit

AWS WAF is actively protecting the CloudFront distribution for armadawgs-growl.click.
During the reporting period, the WAF successfully detected and blocked multiple malicious requests, including SQL injection attempts targeting the /api/public-feed endpoint. All attacks were mitigated at the CloudFront edge, preventing them from reaching the application or ALB.

The WAF is functioning as intended and demonstrates effective protection against common web‑based threats.
       



4) Change proof (CloudTrail)
CloudTrail has event history with a 90-day immutable record of management events
AWS CloudTrail automatically records all management‑level API activity across the account, providing a 90‑day immutable history of configuration changes. This includes the exact moment the WAF was associated with the CloudFront distribution.

Below is a representative CloudTrail event showing the UpdateDistribution API call that attached the WAF to CloudFront.

Students capture:
        --> “who changed SG / TGW route / WAF / CloudFront config”
        Change made: Regional scope in WAF, into a Cloudfront scope
        <img width="1147" height="440" alt="image" src="https://github.com/user-attachments/assets/d6565a76-c4c3-48b7-87ed-47e2c7a85e88" />
        <img width="1300" height="337" alt="image" src="https://github.com/user-attachments/assets/f9218b3b-7699-4487-8738-f6347271b565" />
        cloudfront logs where set to disabled, needed to enable to send logs to s3 buckets
        <img width="1051" height="230" alt="image" src="https://github.com/user-attachments/assets/524182f1-b35c-4363-87e0-061462357240" />




5) Network corridor proof (TGW)
Students prove:
        TGW attachments exist in both regions
        routes point cross-region CIDRs to TGW
   <img width="1001" height="332" alt="image" src="https://github.com/user-attachments/assets/6d0996c1-910d-44d5-a275-8de51d905595" />
   <img width="1008" height="347" alt="image" src="https://github.com/user-attachments/assets/b0b4aa32-d425-4aa3-893b-3ceb3c4c6b7a" />



7) AWS CLI verification (students can prove the bucket/logs exist)

        aws s3 ls s3://Class_Lab3/
        # If logs are under a folder/prefix:
        aws s3 ls s3://Class_Lab3/cloudfront-logs/ --recursive | tail -n 20
   <img width="1052" height="272" alt="image" src="https://github.com/user-attachments/assets/43078e08-171e-49e4-bea3-3cae3756e718" />
   <img width="1027" height="551" alt="image" src="https://github.com/user-attachments/assets/25ae8061-1333-47fe-8cd0-686ed5d4d6c0" />
   <img width="1671" height="245" alt="image" src="https://github.com/user-attachments/assets/d56f16df-0b17-4ea1-a393-a05b8d4b5f67" />




Download one file manually (sanity check):

    aws s3 cp s3://Class_Lab3/cloudfront-logs/<somefile>.gz .
  <img width="1447" height="158" alt="image" src="https://github.com/user-attachments/assets/820db7f4-65ea-409a-baf9-6b46abff2846" />
  <img width="1866" height="658" alt="image" src="https://github.com/user-attachments/assets/c4ac7dc1-363f-4ce6-aea4-b0f3b91b16eb" />



Script 1 — malgus_residency_proof.py
Creates a “DB only in Tokyo” proof file.
<img width="1337" height="482" alt="Screenshot 2026-03-11 012859" src="https://github.com/user-attachments/assets/59697407-e063-4999-9d5e-e38b90f58633" />


Script 2 — malgus_tgw_corridor_proof.py
Shows TGW attachments + routes that form the “legal corridor”.
<img width="1197" height="501" alt="image" src="https://github.com/user-attachments/assets/e0a605e3-0886-45ac-9403-e565379bc0ee" />


Script 3 — malgus_cloudtrail_last_changes.py
Pulls recent CloudTrail events for “who changed what”.
        --> Event history is available by default; it provides a 90-day record of management events.
        <img width="1211" height="451" alt="image" src="https://github.com/user-attachments/assets/3d6447f8-d5af-4cef-aa4a-a61a8e66e7ff" />
        <img width="1217" height="455" alt="image" src="https://github.com/user-attachments/assets/54d40429-7564-4fd2-8039-4fe9d4524165" />
        <img width="1207" height="442" alt="image" src="https://github.com/user-attachments/assets/4259b3c6-0002-46de-af0f-43eb9e78291c" />
        <img width="1211" height="486" alt="image" src="https://github.com/user-attachments/assets/b7076c1b-9e30-4347-9f4f-03be9502a32a" />
        <img width="1206" height="517" alt="image" src="https://github.com/user-attachments/assets/47a7e8bf-a990-41c0-88a4-30027aed65ca" />
        <img width="1198" height="482" alt="image" src="https://github.com/user-attachments/assets/30e8902e-5ad2-4963-a659-c7981fa827ba" />







Script 4 — malgus_waf_summary.py
Summarizes WAF logs (Allow vs Block) from CloudWatch Logs destination.
WAF logging destinations: CloudWatch Logs, S3, Firehose.

Script 5 — malgus_cloudfront_log_explainer.py (optional)
If you ingest CloudFront standard logs into S3, this script reads a log file and counts Hit/Miss/RefreshHit.
<img width="1190" height="486" alt="image" src="https://github.com/user-attachments/assets/3348ff28-cb6d-4621-b59d-eee21aed95ea" />


CloudFront standard logs reference Hit / RefreshHit semantics. 
A) Standard logs in S3 (downloaded locally)

        python3 malgus_cloudfront_log_explainer.py --mode standard cloudfront.log.gz
        python3 malgus_cloudfront_log_explainer.py --mode standard cloudfront_part1.log cloudfront_part2.log

B) Real-time logs as JSON lines

        python3 malgus_cloudfront_log_explainer.py --mode realtime realtime_logs.jsonl
  <img width="261" height="232" alt="image" src="https://github.com/user-attachments/assets/33cb6cef-04ea-4426-b77e-7f8448430762" />


Final Lab Assumptions (Locked)
    S3 Bucket: Class_Lab3
    CloudFront Logs Prefix: Chwebacca-logs/ ← intentionally misspelled
    AWS Account ID: 200819971986

Running Scripts:

        python3 malgus_cloudfront_log_explainer.py --latest 5
  <img width="1217" height="500" alt="image" src="https://github.com/user-attachments/assets/cc63e4d2-8cbd-4468-8289-d95882eb4e3c" />

        python3 malgus_cloudfront_log_explainer.py --prefix cloudfront-logs/ --latest 10
  <img width="1237" height="542" alt="image" src="https://github.com/user-attachments/assets/509eb7d9-be12-48d5-8d45-537958063c87" />

        python3 malgus_cloudfront_log_explainer.py --prefix cloudfront-logs/ --latest 5 --keep
  <img width="1192" height="516" alt="image" src="https://github.com/user-attachments/assets/addb627a-3f2b-406d-bc1e-9b868360ae8a" />



From stdin (nice for pipelines)

        zcat cloudfront.log.gz | python3 malgus_cloudfront_log_explainer.py --mode standard -

Where “Hit / Miss / RefreshHit” come from (student-facing truth)
    In standard CloudFront logs, you usually read the field:
        x-edge-result-type (primary)
        sometimes also x-edge-response-result-type

    Values commonly include: Hit, Miss, RefreshHit, plus other states like Error, LimitExceeded, etc.
  <img width="966" height="192" alt="image" src="https://github.com/user-attachments/assets/5b37299d-41ce-4d95-b882-897e812e922d" />
  The original terraform cache policy was disabled, so the cloudfront could not give a hit, or refreshHit response. Changed to able the cache policy.


That’s why the script reports “Other:*” — so students don’t blindly ignore unusual outcomes.
