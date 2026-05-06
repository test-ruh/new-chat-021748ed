#!/usr/bin/env bash
# Auto-generated script for manage-rerun-and-diff
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="manage-rerun-and-diff"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${DATABASE_URL:?ERROR: DATABASE_URL not set}"
: "${ORG_ID:?ERROR: ORG_ID not set}"
: "${AGENT_ID:?ERROR: AGENT_ID not set}"
: "${RUN_ID:?ERROR: RUN_ID not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/payload_${RUN_ID}.json"
OUTPUT_FILE="/tmp/manage-rerun-and-diff_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os,json,uuid,datetime
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'; p=Path(os.environ.get('INPUT_FILE') or f'/tmp/payload_{run_id}.json')
data=json.load(open(p)) if p.exists() else {}; payload=data.get('payload',data)
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(map(str,p))))
project=data.get('project') or payload.get('project') or {}; pid=project.get('project_id') or payload.get('project_id')
stage=payload.get('requested_stage') or os.environ.get('REQUESTED_STAGE','unspecified'); reason=payload.get('rerun_reason') or os.environ.get('RERUN_REASON','not provided')
diff={'revision_diff_id':hid(run_id,'diff',payload.get('base_stage_run_id'),stage),'project_id':pid,'base_pipeline_run_id':payload.get('base_pipeline_run_id'),'revised_pipeline_run_id':payload.get('pipeline_run_id') or run_id,'base_stage_run_id':payload.get('base_stage_run_id'),'revised_stage_run_id':run_id,'diff_type':'stage_rerun','summary':f'Rerun requested for {stage}: {reason}','details':{'requested_stage':stage,'rerun_reason':reason,'changed_inputs':payload.get('changed_inputs',[]),'pricing_config_id':payload.get('pricing_config_id'),'compare_targets':['estimate_lines','rfis','qa_findings','assumptions','risks','artifacts']},'created_at':now,'run_id':run_id}
audit=[{'audit_log_id':hid(run_id,'rerun',stage),'project_id':pid,'entity_type':'stage_run','entity_id':run_id,'action':'manage_rerun_and_diff','actor':payload.get('requested_by') or 'reviewer','details':diff['details'],'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'requested_stage':stage,'rerun_reason':reason,'revision_diff':diff,'audit_logs':audit,'next_action':'invoke_selected_stage_and_downstream_dependents','blocked':False}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2)); Path(f'/tmp/manage-rerun-and-diff_diffs_{run_id}.json').write_text(json.dumps([diff])); Path(f'/tmp/manage-rerun-and-diff_audit_{run_id}.json').write_text(json.dumps(audit))
print(json.dumps({'event':'stage_complete','skill':'manage-rerun-and-diff','run_id':run_id,'requested_stage':stage}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_revision_diffs --conflict "revision_diff_id" --run-id "${RUN_ID}" --records "$(cat /tmp/manage-rerun-and-diff_diffs_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/manage-rerun-and-diff_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: manage-rerun-and-diff complete"
