Verification commands (CLI) for Bonus-B

ALB exists and is active

aws elbv2 describe-load-balancers
--names chewbacca-alb01
--query "LoadBalancers[0].State.Code"
<img width="1563" height="623" alt="Screenshot 2026-01-26 220546" src="https://github.com/user-attachments/assets/4749973a-151c-41a5-9e15-fff34adb1393" />




HTTPS listener exists on 443

aws elbv2 describe-listeners
--load-balancer-arn <ALB_ARN>
--query "Listeners[].Port"


Target is healthy

aws elbv2 describe-target-health
--target-group-arn <TG_ARN>

WAF attached

aws wafv2 get-web-acl-for-resource
--resource-arn <ALB_ARN>

Alarm created (ALB 5xx)

aws cloudwatch describe-alarms
--alarm-name-prefix chewbacca-alb-5xx
<img width="1821" height="509" alt="Screenshot 2026-01-19 152203" src="https://github.com/user-attachments/assets/4d00545a-155b-46d8-a0f7-1fc3ab6adcbb" />




Dashboard exists

aws cloudwatch list-dashboards
--dashboard-name-prefix chewbacca
