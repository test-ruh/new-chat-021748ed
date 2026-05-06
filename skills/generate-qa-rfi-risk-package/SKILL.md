---
name: generate-qa-rfi-risk-package
version: 1.0.0
description: "Runs Darrow-style QA and produces RFIs, assumptions, exclusions, risks, and alternates."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID, RUN_ID, ANTHROPIC_API_KEY, OPENAI_API_KEY]
    primaryEnv: ANTHROPIC_API_KEY
---
# Generate QA RFI Risk Package

## I/O Contract

- **Input:** `/tmp/apply-pricing-rules_${RUN_ID}.json`
- **Output:** `/tmp/generate-qa-rfi-risk-package_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
