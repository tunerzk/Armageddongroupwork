Lab 2B-Honors+: CloudFront Invalidation as a Controlled Operation
Objective
Students will:
1) Keep origin-driven caching for /api/public-feed (as in Honors)
2) Use versioned static assets for normal deployments (preferred)
3) Use CloudFront invalidation only for approved “break glass” events
4) Prove correctness with x-cache, Age, and invalidation status

AWS CLI provides create-invalidation for this workflow.


The Operational Rules (non-negotiable)

Rule 1 — Never invalidate /* for deployments
That’s the “Chewbacca Rage Invalidation™”. You only use it if:
    security incident
    corrupted content
    legal takedown
    catastrophic caching misconfig
(And you document why.)


CloudFront is saying:

“This file is immutable. You should version it. I will not invalidate it.”

Rule 2 — Prefer versioning for static
Example: /static/app.<hash>.js
No invalidation required; you deploy new file with a new name and update the HTML reference. AWS recommends versioning when you update frequently. 
    Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html?utm_source=chatgpt.com


Rule 3 — Invalidate only the smallest blast radius
Examples:
    /static/index.html
    /static/manifest.json
    /static/* (acceptable only if you can justify)

Rule 4 — Budget/limits awareness
    First 1,000 invalidation paths/month free, then billed per path; wildcard counts as one path.

Part A — Add “break glass” invalidation procedure (CLI)
A1) Create an invalidation (single path

    aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/static/index.html"

AWS shows this exact CLI pattern.

A2) Create an invalidation (wildcard path)
<img width="1471" height="436" alt="image" src="https://github.com/user-attachments/assets/475e59eb-fdb5-4b85-b28e-b531b8d78fc8" />



    aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/static/*"

Wildcards are allowed, but must be last character and paths must start with /
Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/invalidation-specifying-objects.html?utm_source=chatgpt.com

A3) Track invalidation completion

    aws cloudfront get-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --id <INVALIDATION_ID>
  <img width="1442" height="530" alt="image" src="https://github.com/user-attachments/assets/61e663bb-5fdb-465c-9eb6-de862a32b892" />


Part B — “Correctness Proof” checklist (must submit)
B1) Before invalidation: prove object is cached

    curl -i https://chewbacca-growl.com/static/index.html | sed -n '1,30p'
    curl -i https://chewbacca-growl.com/static/index.html | sed -n '1,30p'
    <img width="1462" height="515" alt="image" src="https://github.com/user-attachments/assets/0bf10fe8-c4cc-4f84-b4d5-f15603e97f93" />


Expected:
    Age increases on second request (cached)
    x-cache shows Hit from cloudfront (or similar)
    AWS documents cache result types and hit/miss concepts.
Documenatation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cache-statistics.html?utm_source=chatgpt.com

B2) Deploy change (simulate)
Students must update index.html content at origin (or change static file).
<img width="1398" height="363" alt="image" src="https://github.com/user-attachments/assets/d71a9de1-96a1-42a4-9dde-ff11b77be739" />
<img width="1427" height="291" alt="image" src="https://github.com/user-attachments/assets/821b4430-1da5-4921-8083-671093bce8ae" />



B3) After invalidation: prove cache refresh
Run invalidation for /static/index.html, then:
<img width="1511" height="468" alt="image" src="https://github.com/user-attachments/assets/e5691901-9a59-46db-b97b-455e28313bb0" />
<img width="1482" height="266" alt="image" src="https://github.com/user-attachments/assets/6d7bec24-1004-40ce-adf6-d3a1048027d9" />



    curl -i https://chewbacca-growl.com/static/index.html | sed -n '1,30p'

Expected:
    x-cache is Miss or RefreshHit depending on TTL/conditional validation
    CloudFront standard logs define Hit, Miss, RefreshHit.
Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logs-reference.html?utm_source=chatgpt.com

Part C — Terraform “framework” (two options)
Option 1 (Recommended): Keep invalidations as manual runbook ops
    Terraform should not constantly invalidate on apply; that trains bad habits.

    Terraform should not automatically invalidate CloudFront on every apply.
Why?

Because if Terraform invalidates on every deploy:

You train your team to rely on invalidation instead of proper cache‑busting.

You create unnecessary cost (invalidations aren’t free at scale).

You hide deeper problems (like immutable caching or missing versioning).

You break the principle of declarative infrastructure (Terraform shouldn’t manage ephemeral operations).
I chose Option 1 because CloudFront invalidations should remain a manual, controlled operational action rather than something Terraform performs automatically.  
Invalidations are expensive and should only be used in break‑glass situations. Automating them in Terraform would encourage bad habits, such as relying on invalidation instead of proper asset versioning. Terraform’s job is to manage long‑lived infrastructure, not ephemeral cache‑purge operations.

By keeping invalidations as a manual runbook step, we ensure that:

teams think carefully before invalidating

we avoid unnecessary cost

we preserve Terraform’s declarative model

we encourage correct versioned static asset deployment

This aligns with AWS best practices and the intent of the lab.

Option 2 (Advanced/Optional): “Terraform action” invalidation
    HashiCorp provides a CloudFront invalidation action (not a core resource) that creates invalidations and waits.

Add file: lab2b_honors_plus_invalidation_action.tf

Part D — Incident Scenario (graded)
Scenario: “Stale index.html after deployment”
    Symptoms:
    users keep receiving old index.html which references old hashed assets
    static asset caching works, but the HTML entrypoint is stale

Required student response:
    Confirm caching (Age, x-cache)
    Explain why versioning is preferred but why entrypoint sometimes needs invalidation
    Invalidate /static/index.html only (not /*)
    Verify new content served
    Write a short incident note (2–5 sentences)

   After a deployment, users continued receiving a stale index.html that referenced outdated hashed assets. Investigation showed CloudFront was serving an immutable cached version of the HTML entrypoint (X‑Cache: Hit), even though the origin had the updated file. Static assets are normally versioned, but the HTML entrypoint cannot be, so a targeted invalidation of /static/index.html was required. After invalidation, CloudFront began serving the updated version and the issue was resolved. 
    
Static assets (CSS, JS, images) should always be versioned (e.g., app.abc123.js)
Versioning avoids invalidations and ensures clients always fetch the new file, but the HTML entrypoint (index.html) cannot be versioned because browsers always request / or /index.html Therefore, when the HTML changes but CloudFront cached it as immutable, the only fix is a targeted invalidation.
You can note that in your environment, the file was cached as immutable, so a wildcard invalidation was required — that’s actually a great real‑world insight.

Part E — “Smart” upgrade (extra credit)
E1) Explain when not to invalidate
  If the only changed files are versioned assets like:

    /static/app.9f3c1c7.js
then invalidation is unnecessary. AWS recommends versioned names for frequent updates. 
AWS Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html?utm_source=chatgpt.com

E2) Create “invalidation budget”
Students must state:
    monthly invalidation path budget (e.g., 200)
    allowed wildcard usage conditions
    approval workflow for /*

Student Submission (Honors+)
Students submit:
    1) CLI command used (create-invalidation) + invalidation ID  Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/example_cloudfront_CreateInvalidation_section.html?utm_source=chatgpt.com
    <img width="1286" height="167" alt="image" src="https://github.com/user-attachments/assets/8bf169d4-cb0f-4cff-af74-6cb7c2461134" />
    /static/index.html was the intended target, but immutable caching required a wildcard invalidation.)

    2) Proof of cache before + after (headers showing Age/x-cache) Documentation: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logs-reference.html?utm_source=chatgpt.com
    <img width="1421" height="299" alt="Screenshot 2026-02-15 184335" src="https://github.com/user-attachments/assets/6e1e5cb9-bdf6-4214-8a68-30f6c57c57d0" />
    <img width="1434" height="318" alt="Screenshot 2026-02-15 184612" src="https://github.com/user-attachments/assets/34cfee74-d415-448b-beac-a19307c8e9ad" />


    3) A 1-paragraph policy:
        “When do we invalidate?”
       
        “When do we version instead?”
        
        “Why is /* restricted?”
        
        We only perform CloudFront invalidations when absolutely necessary, such as when the HTML entrypoint (index.html) becomes stale after deployment. All static assets (CSS, JS, images) must be versioned using hashed filenames so they never require invalidation and can be cached indefinitely. The HTML entrypoint cannot be versioned because browsers always request / or /index.html, so it may occasionally require a targeted invalidation. Wildcard invalidations (/*) are restricted because they are expensive, slow, and purge the entire global cache, which can cause performance degradation and unnecessary cost. Targeted invalidations should always be preferred.











