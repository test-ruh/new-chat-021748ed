# Step 5 of 5 — Access

## User Access

### Authorized Teams

| Team               | Access Level | Members (approx) |
|--------------------|-------------|-------------------|
| ECC estimators | Start runs, view status/artifacts, answer intake questions, request reruns, provide project feedback | Named ECC estimator users and configured estimator distribution lists |
| Darrow/reviewers | Approve/reject/revise estimates, answer RFIs, authorize overrides, request stage reruns, mark calibration candidates | Darrow and ECC reviewer users |
| ECC managers/admins | Configure markets, trades, pricing workbook versions, thresholds, folder conventions, notification recipients, connectors, and memory approval policy | ECC estimating managers and Ruh/ECC admins |
| Ruh platform operators | Deploy, provision, monitor environment, maintain secrets and OpenClaw runtime | Authorized Ruh operations staff |

### Restricted From

| Team / Role          | Reason                          |
|----------------------|---------------------------------|
| Subcontractor/package recipients | They consume sub bid packages but are not primary agent operators in Phase 1. |
| Unauthenticated or non-ECC users | Project inputs, estimates, and audit logs are ECC confidential. |
| Model providers | ECC/customer data must not be used for model training or fine-tuning. |

## HiTL Approvers

| Skill                | Action                         | Approver             | Fallback Approver    |
|----------------------|--------------------------------|----------------------|----------------------|
| generate-qa-rfi-risk-package | Override blocker QA/RFI thresholds before package assembly | Darrow/reviewer or ECC manager | Pause run, log blocker RFIs, and notify reviewers. |
| manage-rerun-and-diff | Authorize selected stage rerun and rerun reason | Darrow/reviewer or ECC estimator with reviewer permission | Reject rerun request and preserve current run history. |
| curate-feedback-memory | Promote feedback into approved memory/rule records | Authorized reviewer/admin | Store as proposed memory or project-specific note only. |
| assemble-estimate-artifacts | Final estimate use/approval | Darrow/reviewer | Keep package in draft/review status. |

## Model Configuration

| Field                | Value                          |
|----------------------|--------------------------------|
| **Primary Model**    | claude-sonnet-4   |
| **Fallback Model**   | claude-haiku-3  |

## Token Budget

| Field                  | Value                  |
|------------------------|------------------------|
| **Monthly Budget**     | 20000000 tokens |
| **Alert Threshold**    | 0.8 tokens |
| **Auto-Pause on Limit**| Yes |

## Security & Permissions

| Permission                         | Allowed    |
|------------------------------------|------------|
| read_sharepoint_project_inputs | ✅ |
| write_sharepoint_project_outputs | ✅ |
| receive_companycam_webhooks | ✅ |
| read_companycam_metadata_assets | ✅ |
| read_netsuite_bluecollar_reference_data | ✅ |
| write_netsuite_bluecollar | ❌ |
| send_rfi_and_review_notifications | ✅ |
| train_or_finetune_models | ❌ |
| destructive_database_operations | ❌ |
| independent_stage_rerun | ✅ |
| curated_memory_rule_updates_with_approval | ✅ |
