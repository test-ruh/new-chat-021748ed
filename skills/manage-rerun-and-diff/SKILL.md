---
name: manage-rerun-and-diff
version: 1.0.0
description: Creates controlled stage reruns and structured diffs without overwriting prior history.
user-invocable: true
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID]
    primaryEnv: DATABASE_URL
---
# Manage Rerun and Diff

## I/O Contract

- **Input:** `/tmp/payload_${RUN_ID}.json`
- **Output:** `/tmp/manage-rerun-and-diff_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
