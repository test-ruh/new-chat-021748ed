#!/usr/bin/env bash
# Check required environment variables are set.
set -euo pipefail

missing=0
if [ -z "${PG_CONNECTION_STRING:-}" ]; then echo "MISSING: PG_CONNECTION_STRING"; missing=$((missing+1)); fi
if [ -z "${DATABASE_URL:-}" ]; then echo "MISSING: DATABASE_URL"; missing=$((missing+1)); fi
if [ -z "${ORG_ID:-}" ]; then echo "MISSING: ORG_ID"; missing=$((missing+1)); fi
if [ -z "${AGENT_ID:-}" ]; then echo "MISSING: AGENT_ID"; missing=$((missing+1)); fi
if [ -z "${OPENCLAW_BASE_URL:-}" ]; then echo "MISSING: OPENCLAW_BASE_URL"; missing=$((missing+1)); fi
if [ -z "${SHAREPOINT_CLIENT_ID:-}" ]; then echo "MISSING: SHAREPOINT_CLIENT_ID"; missing=$((missing+1)); fi
if [ -z "${SHAREPOINT_CLIENT_SECRET:-}" ]; then echo "MISSING: SHAREPOINT_CLIENT_SECRET"; missing=$((missing+1)); fi
if [ -z "${SHAREPOINT_TENANT_ID:-}" ]; then echo "MISSING: SHAREPOINT_TENANT_ID"; missing=$((missing+1)); fi
if [ -z "${SHAREPOINT_SITE_ID:-}" ]; then echo "MISSING: SHAREPOINT_SITE_ID"; missing=$((missing+1)); fi
if [ -z "${SHAREPOINT_ROOT_FOLDER_ID:-}" ]; then echo "MISSING: SHAREPOINT_ROOT_FOLDER_ID"; missing=$((missing+1)); fi
if [ -z "${GRAPH_WEBHOOK_CLIENT_STATE:-}" ]; then echo "MISSING: GRAPH_WEBHOOK_CLIENT_STATE"; missing=$((missing+1)); fi
if [ -z "${COMPANYCAM_API_KEY:-}" ]; then echo "MISSING: COMPANYCAM_API_KEY"; missing=$((missing+1)); fi
if [ -z "${COMPANYCAM_WEBHOOK_SECRET:-}" ]; then echo "MISSING: COMPANYCAM_WEBHOOK_SECRET"; missing=$((missing+1)); fi
if [ -z "${GOOGLE_MAPS_API_KEY:-}" ]; then echo "MISSING: GOOGLE_MAPS_API_KEY"; missing=$((missing+1)); fi
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then echo "MISSING: ANTHROPIC_API_KEY"; missing=$((missing+1)); fi
if [ -z "${OPENAI_API_KEY:-}" ]; then echo "MISSING: OPENAI_API_KEY"; missing=$((missing+1)); fi

if [ $missing -gt 0 ]; then
    echo "$missing required env var(s) missing"
    exit 1
fi
echo "OK: all required env vars set"
