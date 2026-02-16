Expected Deliverables
Deliverable A — Terraform
You must submit Terraform that creates/updates:
  1) Two cache policies
    static (aggressive caching)
    api (caching disabled OR origin-driven)

  2) Two origin request policies
    static minimal forwarding
    api forwards required headers/query/cookies (but doesn’t necessarily include them in cache key)

  3) Two cache behaviors
    path_pattern = "/static/*" → static policies
    path_pattern = "/api/*" → api policies

  4) Be A Man Challenge: Response headers policy for explicit Cache-Control on static responses (or security headers)

Deliverable B — Correctness Proof (CLI evidence)
  You must submit:
    A) curl -I outputs for:
        /static/example.txt (must show cache hit behavior)
        <img width="1421" height="299" alt="Screenshot 2026-02-15 184335" src="https://github.com/user-attachments/assets/1b8677ff-831b-46df-b200-dfe319de65fa" />
<img width="1434" height="318" alt="Screenshot 2026-02-15 184612" src="https://github.com/user-attachments/assets/f070eda0-d292-4cd6-85fc-f857bf69b0bc" />

  /api/list (must NOT cache unsafe content)
      

        
   B) A short written explanation:
      “What is my cache key for /api/* and why?”
 My cache key for /api/* includes the full URL path plus all query string parameters, because API responses are dynamic and can change based on request inputs. CloudFront must treat each unique API request as a separate object to avoid serving stale or incorrect data. By including the full query string in the cache key, CloudFront ensures that every distinct API call is forwarded to the origin and never incorrectly reused from cache.    
 
  “What am I forwarding to origin and why?”
  For /api/*, I forward all headers, all query strings, and the request body to the origin because API endpoints often depend on authentication headers, user context, and request parameters. These values directly affect the response, so CloudFront must not strip or normalize them. Forwarding everything ensures the origin receives the complete request exactly as the client sent it, which prevents caching unsafe or user‑specific data and guarantees correctness for dynamic API responses.
      

Deliverable C - Haiku
    You must submit  
      A) Haiku describing Chewbacca's perfections.    
        漢字で。。。英語なし
Across the galaxy,
a loyal, mighty roar—
his fur shining bright.
Chewbacca traveling the galaxy, fiercely loyal, and radiant in his presence.
  

Deliverable D - Technical Verification (CLI) — “Correctness, not vibes”

1) Static caching proof
Run twice:
  curl -I https://chewbacca-growl.com/static/example.txt
  curl -I https://chewbacca-growl.com/static/example.txt
<img width="1382" height="322" alt="image" src="https://github.com/user-attachments/assets/f9ef41e1-619e-4f11-b26f-67885fdfd0a2" />
<img width="1470" height="275" alt="image" src="https://github.com/user-attachments/assets/9ce2a07d-ed28-4d89-ac5e-63224b9b7cf0" />



Look for:
  Cache-Control: public, max-age=... (from response headers policy)
  Age: increases on subsequent requests (cached object indicator) 

  If Age never appears/increases, caching isn’t working (or TTL is 0 / headers prevent caching).

2) API must NOT cache unsafe output
Run twice:
  curl -I https://chewbacca-growl.com/api/list
<img width="1493" height="235" alt="image" src="https://github.com/user-attachments/assets/2f1a05f9-7be8-4ab7-939d-33e791e13282" />

  curl -I https://chewbacca-growl.com/api/list
  <img width="1431" height="108" alt="image" src="https://github.com/user-attachments/assets/855cd10f-5ce0-4507-a318-2c616d0a7f09" />

  

Expected for “safe default” API behavior:
    Age should be absent or 0
    Responses should reflect fresh origin behavior
    If you add auth later, you must never allow one user to see another’s response

3) Cache key sanity checks (query strings)
Static should ignore query strings by default:
  curl -I "https://chewbacca-growl.com/static/example.txt?v=1"
  curl -I "https://chewbacca-growl.com/static/example.txt?v=2"
Expected:
both map to the same cached object (hit ratio stays high) because static cache policy ignores query strings (unless students intentionally change it)
<img width="1480" height="435" alt="image" src="https://github.com/user-attachments/assets/e211a618-90ec-4120-8a8e-6d8ea36ccd58" />


5) “Stale read after write” safety test
  If your API supports writes:
    POST a new row
    Immediately GET /api/list
    Ensure the new row appears
      If it doesn’t, they accidentally cached a dynamic response.
   <img width="551" height="76" alt="image" src="https://github.com/user-attachments/assets/17f15987-b7e4-4531-aa1a-c7974c91f557" />

<img width="1767" height="315" alt="image" src="https://github.com/user-attachments/assets/b0402cf3-73c5-42a4-98a0-d14723a8b83c" />



