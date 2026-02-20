Lab 2 = “Origin Cloaking + CloudFront as the only public ingress.” The clean, realistic interpretation of your requirement (and what big orgs actually do) is:

Only CloudFront is publicly reachable. ALB is still “internet-facing” (because CloudFront must reach it), but it’s cloaked so direct access is blocked: Security Group allows inbound only from the AWS-managed CloudFront origin-facing prefix list (com.amazonaws.global.cloudfront.origin-facing). ALB listener requires a secret custom header that only CloudFront adds. WAF moves to CloudFront (WAFv2 scope = "CLOUDFRONT"), and it is associated to the distribution. chewbacca-growl.com (and app.chewbacca-growl.com) alias to CloudFront.


Lab 2 Architecture

Internet → CloudFront (+ WAF) → ALB (locked to CloudFront) → Private EC2 → RDS

Key constraints
  No one can hit ALB directly (even if they know ALB DNS)
  WAF enforcement happens at CloudFront edge
  DNS points to CloudFront, not ALB


Terraform Overlay: lab2_cloudfront_origin_cloaking.tf

Assumes you already have:
  aws_lb.chewbacca_alb01
  aws_security_group.chewbacca_alb_sg01
  Route53 zone from Bonus-B
  WAF already exists (you’ll replace it with CLOUDFRONT-scoped WAF below)

0) CloudFront must use ACM cert in us-east-1
CloudFront viewer certs must be in N. Virginia (us-east-1). (This is standard AWS behavior; keep it as a lab rule.)
So you will either:
    create a second provider alias for us-east-1, or
    manually create cert and paste ARN (less ideal)

1) Origin cloaking: Allow ALB inbound only from CloudFront prefix list
#lab2_cloudfront_origin_cloaking.tf

Now add/replace your ALB SG ingress:
#lab2_cloudfront_origin_cloaking.tf

Why this works: AWS provides an AWS-managed prefix list for CloudFront origin-facing IP ranges, maintained by AWS.

2) Add a secret “origin header” that ALB requires
CloudFront will add this header, and ALB will only forward requests that contain it. This is the second layer (defense-in-depth), because anyone can create a CloudFront distribution and use the prefix list trick alone isn’t perfect. AWS explicitly documents the “custom header + ALB rule” approach.
#lab2_cloudfront_origin_cloaking.tf

Then on the ALB listener, students add a rule:
If header matches → forward to TG
Else → fixed 403
Terraform-wise, this is aws_lb_listener_rule on your HTTPS listener.
documents the “custom header + ALB rule” approach.
#lab2_cloudfront_origin_cloaking.tf

3) WAF moves to CloudFront (WAFv2 scope CLOUDFRONT)
CloudFront uses global scope Web ACLs (scope = "CLOUDFRONT").
#lab2_cloudfront_shield_waf.tf


4) CloudFront distribution in front of ALB
CloudFront → ALB is a custom origin pattern. You add:
    origin domain = ALB DNS name
    HTTPS only to origin
    custom header X-Chewbacca-Growl with the secret
lab2_cloudfront_alb.tf

WAF association to CloudFront is done via the distribution config (Terraform web_acl_id), consistent with AWS guidance.

5) Route53: point domain to CloudFront (apex + app)
lab2_cloudfront_r53.tf

#####################################
What changes from Lab 1C-Bonus-B
✅ Keep
    private EC2, RDS, SSM, Secrets, incident automation, dashboards, alarms

🔁 Modify
    WAF moves from ALB → CloudFront
    DNS moves from ALB → CloudFront
    ALB is “public” technically, but functionally private (only CloudFront can reach it)

✅ New control points
    CloudFront prefix list SG rule 
    ALB secret header rule

Verification CLI (students must prove all 3 requirements)
1) “VPC is only reachable via CloudFront”
A) Direct ALB access should fail (403)
  curl -I https://<ALB_DNS_NAME>
  <img width="1436" height="115" alt="image" src="https://github.com/user-attachments/assets/7a1ccdd9-1087-47a9-a88e-585035dfdb87" />


Expected: 403 (blocked by missing header)

B) CloudFront access should succeed
  curl -I https://chewbacca-growl.com
  curl -I https://app.chewbacca-growl.com
  <img width="747" height="430" alt="image" src="https://github.com/user-attachments/assets/eef7826c-318c-4429-b48a-72e66ffe0d2c" />
  <img width="1448" height="288" alt="image" src="https://github.com/user-attachments/assets/68e76fd8-69c4-484b-b530-c4f50813022b" />
  <img width="1447" height="235" alt="image" src="https://github.com/user-attachments/assets/c2e9bb82-0980-4cf8-91b5-3ee612ab6eb7" />




Expected: 200/301 → 200

2) WAF moved to CloudFront
  aws wafv2 get-web-acl \
  --name <project>-cf-waf01 \
  --scope CLOUDFRONT \
  --id <WEB_ACL_ID>
  <img width="1802" height="608" alt="image" src="https://github.com/user-attachments/assets/d9e1eeac-e100-455e-83c4-04e11dceefb9" />


And confirm distribution references it:
  aws cloudfront get-distribution \
  --id <DISTRIBUTION_ID> \
  --query "Distribution.DistributionConfig.WebACLId"
  <img width="1416" height="310" alt="image" src="https://github.com/user-attachments/assets/bd2d8bfe-5b96-48bf-8110-bbfd58499a05" />


Expected: WebACL ARN present.

3) chewbacca-growl.com points to CloudFront
  dig chewbacca-growl.com A +short
  dig app.chewbacca-growl.com A +short
<img width="1472" height="238" alt="image" src="https://github.com/user-attachments/assets/f16480f2-aaef-4e9e-ad5c-7d25281714c0" />
<img width="1440" height="232" alt="image" src="https://github.com/user-attachments/assets/368020cd-299d-4060-b942-3a31c46814f3" />



Expected: resolves to CloudFront (you’ll see CloudFront anycast behavior, not ALB IPs)

So at this point:

DNS is correct

CloudFront is active

ALB is forwarding

EC2 is responding

WAF is ready to attach

Everything is aligned.



















