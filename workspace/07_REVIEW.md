# Review — Final Summary Before Deployment

## Agent Card

| Field              | Value                          |
|--------------------|--------------------------------|
| **Name**           | 🧮 ECC Estimating Agent |
| **ID**             | `ecc-estimating-agent`           |
| **Version**        | 1.0.0 |
| **Scope**          | Ruh-hosted cloud OpenClaw agent that turns SharePoint, Company Cam, EagleView, pricing workbook, and reference inputs into ECC reviewer-ready exterior construction estimate artifacts.      |
| **Tone**           | Professional, precise, conservative, estimator-focused, transparent about assumptions and evidence.             |
| **Model**          | claude-sonnet-4 (primary), claude-haiku-3 (fallback) |
| **Token Budget**   | 20000000 tokens/month |

## Skills Summary

| Skill                     | Mode         |
|---------------------------|--------------|
| Data Writer | 🟢 Auto |
| Result Query | 🟢 Auto |
| GitHub Action | 🟢 Auto |
| Ingest Project Inputs | 🟢 Auto |
| Validate Intake | 🟢 Auto |
| Extract Scope Evidence | 🟢 Auto |
| Apply Pricing Rules | 🟢 Auto |
| Generate QA RFI Risk Package | 🟢 Auto |
| Assemble Estimate Artifacts | 🟢 Auto |
| Manage Rerun and Diff | 🟢 Auto |
| Curate Feedback Memory | 🟢 Auto |

## Post-Deployment Checklist

- [ ] Configure Ruh-hosted cloud OpenClaw agent and environment/secrets.
- [ ] Provision database schema using result-schema.yml and verify schema isolation.
- [ ] Register Microsoft Graph SharePoint webhooks and confirm delta watcher schedule.
- [ ] Configure Company Cam webhook secret and delta reconciliation.
- [ ] Validate connector read/write scopes for SharePoint, Company Cam, EagleView, Google Maps, NetSuite, BlueCollar, Outlook/SMTP, Anthropic, and OpenAI.
- [ ] Load approved ECC pricing workbook config including tabs, formulas, write ranges, rates, taxes, markups, and validation checks.
- [ ] Load approved memory/rule references and keep envelope trades disabled until approved.
- [ ] Run check-environment.sh, install-dependencies.sh, and test-workflow.sh.
- [ ] Execute dry-run project and verify SharePoint artifacts, native/email notifications, audit completeness, RFIs, and rerun diff behavior.
- [ ] Monitor first 10 production runs, compare to Darrow benchmarks, review connector health, token/cost usage, no-secret logs, and blocker thresholds.
