# Step 4 of 5 — Triggers

## Active Triggers

### sharepoint-webhook — Microsoft Graph SharePoint webhook/delta event for new or changed files in configured agent-input folders.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | event                     |
| **Status**  | enabled                   |
| **Channel** | SharePoint |

**Sample User Queries This Trigger Handles:**

- "New pricing workbook uploaded"
- "New plan set added to agent-input"

---

### sharepoint-delta-watch — Poll Microsoft Graph delta for configured SharePoint agent-input folders and pricing workbook changes.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | cron                     |
| **Status**  | enabled                   |
| **Cron**        | `*/15 * * * *`                        |

---

### companycam-webhook — Company Cam project/photo/tag/comment webhook for mapped ECC projects.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | event                     |
| **Status**  | enabled                   |
| **Channel** | Company Cam |

---

### companycam-delta-reconcile — Reconcile Company Cam projects/photos/tags/comments in case webhook delivery was missed.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | cron                     |
| **Status**  | enabled                   |
| **Cron**        | `*/30 * * * *`                        |

---

### manual-start-rerun — Estimator or reviewer starts a full pipeline or selected stage rerun from OpenClaw console/dashboard.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | conversational                     |
| **Status**  | enabled                   |
| **Channel** | OpenClaw console |

**Sample User Queries This Trigger Handles:**

- "Start estimate for project 123"
- "Rerun pricing stage with revised workbook"

---

### reviewer-feedback — Reviewer submits approve/reject/revise decision, RFI answer, override, or memory candidate.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | event                     |
| **Status**  | enabled                   |
| **Channel** | OpenClaw console/email association |

---

### connector-health-check — Check connector health and update non-secret status metadata.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | cron                     |
| **Status**  | enabled                   |
| **Cron**        | `0 */6 * * *`                        |

