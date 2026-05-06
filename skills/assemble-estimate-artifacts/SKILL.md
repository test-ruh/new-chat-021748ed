---
name: assemble-estimate-artifacts
version: 1.0.0
description: "Builds the reviewer package, SharePoint sync outputs, audit bundle, and notification payload."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq, date]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID, SHAREPOINT_CLIENT_ID, SHAREPOINT_CLIENT_SECRET, SHAREPOINT_TENANT_ID, SHAREPOINT_SITE_ID]
    primaryEnv: SHAREPOINT_CLIENT_SECRET
---
# Assemble Estimate Artifacts

## I/O Contract

- **Input:** `/tmp/generate-qa-rfi-risk-package_${RUN_ID}.json`
- **Output:** `/tmp/assemble-estimate-artifacts_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
