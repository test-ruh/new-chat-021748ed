---
name: ingest-project-inputs
version: 1.0.0
description: "Retrieves and normalizes SharePoint, Company Cam, EagleView, and manual project inputs."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, curl, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID, SHAREPOINT_CLIENT_ID, SHAREPOINT_CLIENT_SECRET, SHAREPOINT_TENANT_ID, SHAREPOINT_SITE_ID, SHAREPOINT_ROOT_FOLDER_ID, COMPANYCAM_API_KEY, COMPANYCAM_WEBHOOK_SECRET]
    primaryEnv: SHAREPOINT_CLIENT_SECRET
---
# Ingest Project Inputs

## I/O Contract

- **Input:** `/tmp/payload_${RUN_ID}.json`
- **Output:** `/tmp/ingest-project-inputs_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
