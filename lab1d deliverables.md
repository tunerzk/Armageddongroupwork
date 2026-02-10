Student verification (CLI) — DNS + Logs

Verify apex record exists aws route53 list-resource-record-sets
--hosted-zone-id <ZONE_ID>
--query "ResourceRecordSets[?Name=='chewbacca-growl.com.']"

Verify ALB logging is enabled aws elbv2 describe-load-balancers
--names chewbacca-alb01
--query "LoadBalancers[0].LoadBalancerArn"
<img width="1335" height="456" alt="Screenshot 2026-02-04 142716" src="https://github.com/user-attachments/assets/2748812e-a5ef-4932-b1a2-9904896234c0" />



Then: aws elbv2 describe-load-balancer-attributes
--load-balancer-arn <ALB_ARN>


Expected attributes include: access_logs.s3.enabled = true access_logs.s3.bucket = your bucket access_logs.s3.prefix = your prefix

Generate some traffic curl -I https://chewbacca-growl.com curl -I https://app.chewbacca-growl.com
<img width="753" height="244" alt="Screenshot 2026-01-27 220504" src="https://github.com/user-attachments/assets/4be7e91f-e52a-45a5-b118-58b6c41c5243" />
<img width="723" height="441" alt="Screenshot 2026-02-03 161055" src="https://github.com/user-attachments/assets/3b1dcc33-8018-409d-bb91-e9b8efd6be78" />



Verify logs arrived in S3 (may take a few minutes) aws s3 ls s3://<BUCKET_NAME>//AWSLogs/<ACCOUNT_ID>/elasticloadbalancing/ --recursive | head

Why this matters to YOU (career-critical point) This is incident response fuel: Access logs tell you: client IPs paths response codes target behavior latency
