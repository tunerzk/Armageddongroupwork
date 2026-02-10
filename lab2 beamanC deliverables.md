Lab 2B-Honors++
CloudFront Validators, RefreshHit, and Conditional Requests
What this lab teaches (in one sentence)

A CDN can revalidate cached objects without fully refetching them — and that’s not a bug.

1. Mental Model (Teach This First)
CloudFront cache outcomes you care about:

| x-cache value                | Meaning                                                                  |
| ---------------------------- | ------------------------------------------------------------------------ |
| `Hit from cloudfront`        | Served entirely from cache                                               |
| `Miss from cloudfront`       | Fetched from origin                                                      |
| `RefreshHit from cloudfront` | Cached object existed, but CloudFront **revalidated** it with the origin |
| `Error from cloudfront`      | Origin or edge error                                                     |


Key insight
RefreshHit means:
    CloudFront did go to the origin
    But used conditional headers (If-None-Match, If-Modified-Since)
    Origin said 304 Not Modified
    CDN reused cached body

➡️ Lower bandwidth than a Miss, higher latency than a Hit

This is normal when:
    TTL expires
    Cache-Control: max-age is short
    Origin sends validators (ETag / Last-Modified)



    You must explain:
    Why invalidation works
    Why it’s not the preferred fix
    Why updating validators is better

    Deliverables:
12. One-Paragraph Takeaway (You Must Write)
    --> “What does RefreshHit mean, and why is it often better than a Miss?”
If they can answer this cleanly, they’re ahead of most working engineers.

