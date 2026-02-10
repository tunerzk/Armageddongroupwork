Student verification (CLI) A) Confirm WAF logging is enabled (authoritative) aws wafv2 get-logging-configuration
--resource-arn <WEB_ACL_ARN>
Expected: LogDestinationConfigs contains exactly one destination.



B) Generate traffic (hits + blocks) curl -I https://chewbacca-growl.com/ curl -I https://app.chewbacca-growl.com/

C1) If CloudWatch Logs destination aws logs describe-log-streams
--log-group-name aws-waf-logs--webacl01
--order-by LastEventTime --descending
<img width="1490" height="418" alt="Screenshot 2026-02-04 153642" src="https://github.com/user-attachments/assets/966c373a-7abe-4e3c-9c6e-2055ef04e0fa" />



Then pull recent events: aws logs filter-log-events
--log-group-name aws-waf-logs--webacl01
--max-items 20
<img width="1489" height="436" alt="Screenshot 2026-02-04 153926" src="https://github.com/user-attachments/assets/3acd2119-a353-4c3e-aaef-901cba291003" />



C2) If S3 destination aws s3 ls s3://aws-waf-logs--<account_id>/ --recursive | head

C3) If Firehose destination aws firehose describe-delivery-stream
--delivery-stream-name aws-waf-logs--firehose01
--query "DeliveryStreamDescription.DeliveryStreamStatus"

And confirm objects land: aws s3 ls s3://<firehose_dest_bucket>/waf-logs/ --recursive | head

Why this makes incident response “real” Now you can answer questions like: “Are 5xx caused by attackers or backend failure?” “Do we see WAF blocks spike before ALB 5xx?” “What paths / IPs are hammering the app?” “Is it one client, one ASN, one country, or broad?” “Did WAF mitigate, or are we failing downstream?”
This is precisely why WAF logging destinations include CloudWatch Logs (fast search) and S3/Firehose (archive/SIEM pipeline)
