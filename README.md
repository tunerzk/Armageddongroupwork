“I designed a multi-region medical application where all PHI remained in Japan to comply with APPI.
CloudFront provided global access, São Paulo ran stateless compute only, and all reads/writes traversed a Transit Gateway to Tokyo RDS.
The design intentionally traded some latency for legal certainty and auditability.”
