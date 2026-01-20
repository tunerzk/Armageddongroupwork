Lab 1b — Operations, Secrets, and Incident Response Prerequisite: Lab 1a completed and verified

Project Overview (What This Lab Is About) In Lab 1a, you built a working system. In Lab 1b, you will operate, observe, break, and recover that system. You will extend your EC2 → RDS application to include: Dual secret storage AWS Systems Manager Parameter Store AWS Secrets Manager Centralized logging via CloudWatch Logs Automated alarms when database connectivity fails Incident-response actions using previously saved values
This lab simulates what happens after deployment, which is where most real cloud work lives.

Why This Lab Exists (Real-World Context) Most cloud failures are not caused by: Bad code Missing features Wrong instance sizes
They are caused by: Credential issues Secret rotation failures Misconfigured access Silent connectivity loss Poor observability

This lab teaches you how to design for failure, detect it early, and recover using stored configuration data.

Workforce Relevance (Why Employers Care) This Lab Maps Directly to Job Responsibilities In the workforce, you will be expected to: Know where secrets live Understand why multiple secret systems exist Diagnose outages using logs and metrics Respond to incidents without redeploying everything Restore service quickly using known-good configuration
This is the difference between: “I can deploy AWS resources” and “I can keep systems running under pressure”

Parameter Store vs Secrets Manager (Conceptual) You will store database connection values in both systems and intentionally use them during recovery. AWS Systems Manager Parameter Store Best for: Configuration values Non-rotating data Shared application parameters
Supports: Plain text SecureString (encrypted)

Often used for: Feature flags Endpoints Environment configuration

AWS Secrets Manager Best for: Credentials Passwords Rotating secrets

Supports: Automatic rotation Tight audit integration

Often used for: Database passwords API keys

Industry Reality: Many environments use both — intentionally.

What You Are Building in Lab 1b New Capabilities Added
Store DB values in Parameter Store
Store DB credentials in Secrets Manager
Log application DB connection failures to CloudWatch Logs
Create a CloudWatch Alarm that triggers when failures exceed a threshold
Simulate a DB outage or credential failure
Recover the system using saved parameters/secrets without redeploying EC2


Expected Deliverables (What You Must Produce) 

A. Configuration Artifacts Parameter Store entries for: DB endpoint DB port DB name
<img width="1829" height="477" alt="Screenshot 2026-01-18 142920" src="https://github.com/user-attachments/assets/30572501-06d4-43c5-8e2e-79e8d9cc221c" />


Secrets Manager secret for: DB username/password
<img width="1647" height="190" alt="Screenshot 2026-01-13 210757" src="https://github.com/user-attachments/assets/f7f4b855-6951-4d4c-8d9c-f0994cf3eb43" />
<img width="1691" height="227" alt="Screenshot 2026-01-13 210328" src="https://github.com/user-attachments/assets/86a4b585-4d4f-4f6b-b845-ce177155ba35" />
<img width="1842" height="426" alt="Screenshot 2026-01-18 143117" src="https://github.com/user-attachments/assets/bfb181f3-d4e2-4017-b3fe-be4bf59b3c1f" />


Log application DB connection failures to CloudWatch Logs
<img width="1853" height="779" alt="Screenshot 2026-01-16 202256" src="https://github.com/user-attachments/assets/5f7f97bc-3837-40ce-8ad2-d476b5ca4d29" />
<img width="1839" height="681" alt="Screenshot 2026-01-16 210951" src="https://github.com/user-attachments/assets/c55c7861-06ac-4edc-91a2-df431683502b" />
<img width="1827" height="476" alt="Screenshot 2026-01-18 171726" src="https://github.com/user-attachments/assets/638567fa-6b99-436d-a269-8c7a7089243a" />

Create a CloudWatch Alarm that triggers when failures exceed a threshold
<img width="1821" height="509" alt="Screenshot 2026-01-19 152203" src="https://github.com/user-attachments/assets/69138e3c-32d5-470f-b5be-04caa9063459" />

Simulate a DB outage or credential failure
<img width="1799" height="433" alt="Screenshot 2026-01-19 152808" src="https://github.com/user-attachments/assets/f15b733d-a176-4f8b-b600-9c8ea8f5dc08" />
<img width="1772" height="488" alt="Screenshot 2026-01-19 151240" src="https://github.com/user-attachments/assets/ce4fadb4-131f-4e85-bf46-cd4f42aa6bb3" />



Recover the system using saved parameters/secrets without redeploying EC2
<img width="1839" height="681" alt="Screenshot 2026-01-16 210951" src="https://github.com/user-attachments/assets/7b321dcd-5768-43a6-9fc6-565f23c3092c" />


Incident-Response Focus (What This Lab Teaches) During recovery, you must: Identify failure source via logs Retrieve correct values from: Parameter Store Secrets Manager Restore service using configuration — not guesswork
This mirrors real on-call workflows.

Common Failure Modes (And Why They Matter) | Failure | Real-World Meaning | | -------------------------- | ------------------------- | | Alarm never fires | Poor observability | | Logs lack detail | Weak incident diagnostics | | EC2 can’t read parameters | IAM misdesign | | Recovery requires redeploy | Fragile architecture |

What Completing Lab 1b Proves If you complete this lab, you can confidently say: “I can operate, monitor, and recover AWS workloads using proper secret management and observability.”

That is mid-level engineer capability, not entry-level.

Reflection Questions: Answer all of these A) Why might Parameter Store still exist alongside Secrets Manager? 


B) What breaks first during secret rotation? C) Why should alarms be based on symptoms instead of causes?



D) How does this lab reduce mean time to recovery (MTTR)? E) What would you automate next?


















