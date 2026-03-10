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



And/or submit CloudFront standard log evidence (Hit/Miss/RefreshHit)

3) WAF proof

Provide:
        WAF log snippet or Insights summary
        WAF logging destination options are documented 


4) Change proof (CloudTrail)
CloudTrail has event history with a 90-day immutable record of management events 

Students capture:
        --> “who changed SG / TGW route / WAF / CloudFront config”

5) Network corridor proof (TGW)
Students prove:
        TGW attachments exist in both regions
        routes point cross-region CIDRs to TGW

6) AWS CLI verification (students can prove the bucket/logs exist)

        aws s3 ls s3://Class_Lab3/
        # If logs are under a folder/prefix:
        aws s3 ls s3://Class_Lab3/cloudfront-logs/ --recursive | tail -n 20

Download one file manually (sanity check):

    aws s3 cp s3://Class_Lab3/cloudfront-logs/<somefile>.gz .

Script 1 — malgus_residency_proof.py
Creates a “DB only in Tokyo” proof file.

Script 2 — malgus_tgw_corridor_proof.py
Shows TGW attachments + routes that form the “legal corridor”.

Script 3 — malgus_cloudtrail_last_changes.py
Pulls recent CloudTrail events for “who changed what”.
        --> Event history is available by default; it provides a 90-day record of management events.

Script 4 — malgus_waf_summary.py
Summarizes WAF logs (Allow vs Block) from CloudWatch Logs destination.
WAF logging destinations: CloudWatch Logs, S3, Firehose.

Script 5 — malgus_cloudfront_log_explainer.py (optional)
If you ingest CloudFront standard logs into S3, this script reads a log file and counts Hit/Miss/RefreshHit.

CloudFront standard logs reference Hit / RefreshHit semantics. 
A) Standard logs in S3 (downloaded locally)

        python3 malgus_cloudfront_log_explainer.py --mode standard cloudfront.log.gz
        python3 malgus_cloudfront_log_explainer.py --mode standard cloudfront_part1.log cloudfront_part2.log

B) Real-time logs as JSON lines

        python3 malgus_cloudfront_log_explainer.py --mode realtime realtime_logs.jsonl

Final Lab Assumptions (Locked)
    S3 Bucket: Class_Lab3
    CloudFront Logs Prefix: Chwebacca-logs/ ← intentionally misspelled
    AWS Account ID: 200819971986

Running Scripts:

        python3 malgus_cloudfront_log_explainer.py --latest 5
        python3 malgus_cloudfront_log_explainer.py --prefix cloudfront-logs/ --latest 10
        python3 malgus_cloudfront_log_explainer.py --prefix cloudfront-logs/ --latest 5 --keep


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
