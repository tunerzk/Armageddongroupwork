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
<img width="1342" height="227" alt="image" src="https://github.com/user-attachments/assets/a819d56d-e1c6-454a-8434-a668837571c7" />



Target is healthy

aws elbv2 describe-target-health
--target-group-arn <TG_ARN>
<img width="1782" height="438" alt="image" src="https://github.com/user-attachments/assets/0d8713bd-7a98-4b97-83c2-3ec53ace5efa" />


WAF attached

aws wafv2 get-web-acl-for-resource
--resource-arn <ALB_ARN>

Alarm created (ALB 5xx)

aws cloudwatch describe-alarms
--alarm-name-prefix chewbacca-alb-5xx
<img width="1821" height="509" alt="Screenshot 2026-01-19 152203" src="https://github.com/user-attachments/assets/4d00545a-155b-46d8-a0f7-1fc3ab6adcbb" />




Dashboard exists
<img width="726" height="311" alt="image" src="https://github.com/user-attachments/assets/43fb3d9e-9886-4180-9371-47dc6ffc6ed1" />


aws cloudwatch list-dashboards
--dashboard-name-prefix chewbacca
