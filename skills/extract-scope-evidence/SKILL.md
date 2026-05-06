---
name: extract-scope-evidence
version: 1.0.0
description: "Classifies documents/photos and extracts takeoff, OCR/sketch, scope, and evidence references."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID, ANTHROPIC_API_KEY, OPENAI_API_KEY]
    primaryEnv: ANTHROPIC_API_KEY
---
# Extract Scope Evidence

## I/O Contract

- **Input:** `/tmp/validate-intake_${RUN_ID}.json`
- **Output:** `/tmp/extract-scope-evidence_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
