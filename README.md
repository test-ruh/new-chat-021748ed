# 🧮 ECC Estimating Agent

Ruh-hosted cloud OpenClaw agent that turns SharePoint, Company Cam, EagleView, pricing workbook, and reference inputs into ECC reviewer-ready exterior construction estimate artifacts.

## Quick Start

```bash
git clone git@github.com:${GITHUB_OWNER}/ecc-estimating-agent.git
cd ecc-estimating-agent

# 1. Configure
cp .env.example .env
# Edit .env with your credentials (see "Required Environment Variables" below)

# 2. One-shot setup: validates env, installs deps, provisions DB, registers cron
chmod +x setup.sh
./setup.sh
```

## Manual Setup (if you prefer step-by-step)

```bash
cp .env.example .env             # then edit it
set -a; source .env; set +a       # load vars into the current shell
bash check-environment.sh         # verify everything required is set
bash install-dependencies.sh      # pip install psycopg2-binary, pyyaml
python3 scripts/data_writer.py provision   # create tables in your schema
openclaw cron add --file cron/sharepoint-delta-watch.json
openclaw cron add --file cron/companycam-delta-reconcile.json
openclaw cron add --file cron/connector-health-check.json
```

## Running

```bash
bash test-workflow.sh             # run every skill in order locally (smoke test)
openclaw cron run --name sharepoint-delta-watch    # trigger manually
openclaw cron run --name companycam-delta-reconcile    # trigger manually
openclaw cron run --name connector-health-check    # trigger manually
openclaw cron list                # see registered jobs
openclaw cron runs                # see run history
```

## Required Environment Variables

| Variable | Description |
|----------|-------------|
| `PG_CONNECTION_STRING` | PostgreSQL connection string |
| `DATABASE_URL` | Database URL |
| `ORG_ID` | Organization ID |
| `AGENT_ID` | Agent ID |
| `OPENCLAW_BASE_URL` | OpenClaw base URL |
| `SHAREPOINT_CLIENT_ID` | SharePoint client ID |
| `SHAREPOINT_CLIENT_SECRET` | SharePoint client secret |
| `SHAREPOINT_TENANT_ID` | SharePoint tenant ID |
| `SHAREPOINT_SITE_ID` | SharePoint site ID |
| `SHAREPOINT_ROOT_FOLDER_ID` | SharePoint root folder ID |
| `GRAPH_WEBHOOK_CLIENT_STATE` | Graph webhook client state |
| `COMPANYCAM_API_KEY` | Company Cam API key |
| `COMPANYCAM_WEBHOOK_SECRET` | Company Cam webhook secret |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key |
| `ANTHROPIC_API_KEY` | Anthropic API key |
| `OPENAI_API_KEY` | OpenAI API key |

## Skills

| Skill | Mode | Description |
|-------|------|-------------|
| `data-writer` | Auto | Provision, write, and query the agent database schema via scripts/data_writer.py. Use for all PostgreSQL operations and any result-table persistence. |
| `result-query` | User-invocable | Read stored records from the agent result tables for inspection and follow-up questions. |
| `github-action` | User-invocable | Git branch + PR workflow for syncing agent changes to GitHub. Creates feature branches, commits changes, and opens pull requests against main. NEVER pushes to main directly. MANDATORY for every agent. |
| `ingest-project-inputs` | Auto | Retrieves and normalizes SharePoint, Company Cam, EagleView, and manual project inputs. |
| `validate-intake` | Auto | Validates metadata, project identity, required evidence, supported trades, market/address, and pricing readiness. |
| `extract-scope-evidence` | Auto | Classifies documents/photos and extracts takeoff, OCR/sketch, scope, and evidence references. |
| `apply-pricing-rules` | Auto | Retrieves pricing config/memory references and builds normalized trade estimate lines. |
| `generate-qa-rfi-risk-package` | Auto | Runs Darrow-style QA and produces RFIs, assumptions, exclusions, risks, and alternates. |
| `assemble-estimate-artifacts` | Auto | Builds the reviewer package, SharePoint sync outputs, audit bundle, and notification payload. |
| `manage-rerun-and-diff` | User-invocable | Creates controlled stage reruns and structured diffs without overwriting prior history. |
| `curate-feedback-memory` | User-invocable | Stores reviewer feedback and proposes or approves curated memories/rules without model training. |

## Scheduled Jobs

| Job Name | Schedule | Notes |
|----------|----------|-------|
| `sharepoint-delta-watch` | `*/15 * * * *` | Timezone: UTC |
| `companycam-delta-reconcile` | `*/30 * * * *` | Timezone: UTC |
| `connector-health-check` | `0 */6 * * *` | Timezone: UTC |


## Architecture

- **Runtime**: OpenClaw AI agent framework
- **Data Layer**: PostgreSQL via `scripts/data_writer.py`
- **Scheduling**: OpenClaw cron
- **Schema**: `org_{org_id}_a_ecc_estimating_agent`

## Directory Structure

```
ecc-estimating-agent/
├── README.md
├── openclaw.json
├── result-schema.yml
├── env-manifest.yml
├── .env.example
├── requirements.txt
├── .gitignore
├── check-environment.sh
├── install-dependencies.sh
├── test-workflow.sh
├── cron/
├── workflows/
├── scripts/
│   ├── data_writer.py
│   └── github_action.py
├── skills/
└── workspace/
    ├── SOUL.md
    ├── 01_IDENTITY.md
    ├── 02_RULES.md
    ├── 03_SKILLS.md
    ├── 04_TRIGGERS.md
    ├── 05_ACCESS.md
    ├── 06_WORKFLOW.md
    └── 07_REVIEW.md
```
