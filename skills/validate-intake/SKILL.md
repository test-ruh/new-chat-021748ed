---
name: validate-intake
version: 1.0.0
description: "Validates metadata, project identity, required evidence, supported trades, market/address, and pricing readiness."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID, GOOGLE_MAPS_API_KEY]
    primaryEnv: GOOGLE_MAPS_API_KEY
---
# Validate Intake

## I/O Contract

- **Input:** `/tmp/ingest-project-inputs_${RUN_ID}.json`
- **Output:** `/tmp/validate-intake_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
