---
name: curate-feedback-memory
version: 1.0.0
description: Stores reviewer feedback and proposes or approves curated memories/rules without model training.
user-invocable: true
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID]
    primaryEnv: DATABASE_URL
---
# Curate Feedback Memory

## I/O Contract

- **Input:** `/tmp/payload_${RUN_ID}.json`
- **Output:** `/tmp/curate-feedback-memory_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
