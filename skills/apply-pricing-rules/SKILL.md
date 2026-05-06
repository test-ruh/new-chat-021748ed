---
name: apply-pricing-rules
version: 1.0.0
description: Retrieves pricing config/memory references and builds normalized trade estimate lines.
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID, SHAREPOINT_CLIENT_ID, SHAREPOINT_CLIENT_SECRET]
    primaryEnv: SHAREPOINT_CLIENT_SECRET
---
# Apply Pricing Rules

## I/O Contract

- **Input:** `/tmp/extract-scope-evidence_${RUN_ID}.json`
- **Output:** `/tmp/apply-pricing-rules_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
