# Step 2 of 5 — Rules

## Custom Agent Rules

| #    | Rule                  | Category        |
|------|-----------------------|-----------------|
| ECC1   | Run only in Ruh-hosted cloud OpenClaw runtime; do not assume local, desktop-only, on-premises, Docker, crontab, or Kubernetes deployment. | deployment |
| ECC2   | Do not invent scope, quantities, prices, rates, taxes, markups, workbook mappings, or reviewer decisions; use RFIs, assumptions, or blockers when evidence/config is incomplete. | estimating |
| ECC3   | Draft estimates are not final until Darrow/reviewer approval or authorized override is logged. | review |
| ECC4   | Every material input, output, stage run, rerun reason, artifact, estimate line, RFI, QA finding, assumption, risk, pricing config, and reviewer decision must be auditable. | audit |
| ECC5   | Pricing workbook tabs, protected cells, formulas, allowed write ranges, rates, taxes, markups, markets, trades, thresholds, recipients, and memory policies must be configurable and versioned. | configuration |
| ECC6   | Never train or fine-tune models on ECC/customer data; store only allowed redacted prompt/response metadata and source-grounded outputs. | security |
| ECC7   | NetSuite and BlueCollar are read-only in Phase 1; SharePoint writes are limited to configured project output folders; Company Cam is inbound/read-only in Phase 1. | connectors |
| ECC8   | Phase 1 supports paint, roofing, and carpentry; Phase 1.5 envelope trades remain disabled until approved mappings, takeoff rules, and QA checks exist. | trades |
| ECC9   | Any stage rerun must create new stage-run and revision-diff records rather than deleting or overwriting prior history. | reruns |

## Inherited Org Soul Rules (Cannot Be Removed)

| #    | Rule                  | Source          |
|------|-----------------------|-----------------|
| OS1  | Never perform DROP, DELETE, TRUNCATE, or ALTER TABLE operations on any database | Org Admin |
| OS2  | Never access or write to schemas outside the agent's own schema (`org_{ORG_ID}_a_{AGENT_ID}`) | Org Admin |
| OS3  | Never store credentials, API keys, or tokens in any file committed to the repository | Org Admin |
| OS4  | Respect API rate limits — add backoff/retry on HTTP 429 responses | Org Admin |
| OS5  | All external API calls must validate HTTP status codes and handle non-2xx responses explicitly | Org Admin |

## Rule Enforcement Summary

| Metric                  | Value                      |
|-------------------------|----------------------------|
| Total Custom Rules      | 9 |
| Total Inherited Rules   | 5 |
| **Total Active Rules**  | **14**               |
