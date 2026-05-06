# Step 3 of 5 — Skills

## Added Skills

| #    | Skill ID                  | Skill Name               | Mode   | Risk Level | Description                |
|------|---------------------------|--------------------------|--------|------------|----------------------------|
| S1   | `data-writer` | Data Writer | Auto | Low | Provision, write, and query the agent database schema via scripts/data_writer.py. Use for all PostgreSQL operations and any result-table persistence. |
| S2   | `result-query` | Result Query | Auto | Low | Read stored records from the agent result tables for inspection and follow-up questions. |
| S3   | `github-action` | GitHub Action | Auto | Low | Git branch + PR workflow for syncing agent changes to GitHub. Creates feature branches, commits changes, and opens pull requests against main. NEVER pushes to main directly. MANDATORY for every agent. |
| S4   | `ingest-project-inputs` | Ingest Project Inputs | Auto | Low | Retrieves and normalizes SharePoint, Company Cam, EagleView, and manual project inputs. |
| S5   | `validate-intake` | Validate Intake | Auto | Low | Validates metadata, project identity, required evidence, supported trades, market/address, and pricing readiness. |
| S6   | `extract-scope-evidence` | Extract Scope Evidence | Auto | Low | Classifies documents/photos and extracts takeoff, OCR/sketch, scope, and evidence references. |
| S7   | `apply-pricing-rules` | Apply Pricing Rules | Auto | Low | Retrieves pricing config/memory references and builds normalized trade estimate lines. |
| S8   | `generate-qa-rfi-risk-package` | Generate QA RFI Risk Package | Auto | Low | Runs Darrow-style QA and produces RFIs, assumptions, exclusions, risks, and alternates. |
| S9   | `assemble-estimate-artifacts` | Assemble Estimate Artifacts | Auto | Low | Builds the reviewer package, SharePoint sync outputs, audit bundle, and notification payload. |
| S10   | `manage-rerun-and-diff` | Manage Rerun and Diff | Auto | Low | Creates controlled stage reruns and structured diffs without overwriting prior history. |
| S11   | `curate-feedback-memory` | Curate Feedback Memory | Auto | Low | Stores reviewer feedback and proposes or approves curated memories/rules without model training. |

## Skill Dependencies (Execution Order)

```
data-writer
result-query
github-action
ingest-project-inputs
validate-intake ← depends on ingest-project-inputs
extract-scope-evidence ← depends on validate-intake
apply-pricing-rules ← depends on extract-scope-evidence
generate-qa-rfi-risk-package ← depends on apply-pricing-rules
assemble-estimate-artifacts ← depends on generate-qa-rfi-risk-package
manage-rerun-and-diff ← depends on validate-intake, extract-scope-evidence, apply-pricing-rules, generate-qa-rfi-risk-package, assemble-estimate-artifacts
curate-feedback-memory ← depends on manage-rerun-and-diff
```

## Execution Mode Summary

| Mode  | Count          |
|-------|----------------|
| HiTL  | 0              |
| Auto  | 11 |
