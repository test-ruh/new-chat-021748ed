#!/usr/bin/env bash
# Auto-generated script for curate-feedback-memory
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="curate-feedback-memory"
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
OUTPUT_FILE="/tmp/curate-feedback-memory_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os,json,uuid,datetime
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'; p=Path(os.environ.get('INPUT_FILE') or f'/tmp/payload_{run_id}.json')
data=json.load(open(p)) if p.exists() else {}; payload=data.get('payload',data)
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(str(x) for x in p if x is not None)))
project=data.get('project') or payload.get('project') or {}; pid=project.get('project_id') or payload.get('project_id')
items=payload.get('feedback') or payload.get('reviewer_feedback') or ([payload] if payload.get('decision') or payload.get('comment') else [])
feedback=[]; rules=[]
for i,f in enumerate(items):
    fid=f.get('feedback_id') or hid(run_id,'feedback',i,f.get('comment'))
    feedback.append({'feedback_id':fid,'project_id':pid,'target_type':f.get('target_type','package'),'target_id':f.get('target_id'),'decision':f.get('decision','comment'),'comment':f.get('comment') or f.get('calibration_note'),'reviewer':f.get('reviewer') or payload.get('requested_by'),'metadata':{'memory_candidate':bool(f.get('memory_candidate') or f.get('promote_to_memory')),'no_model_training':True},'created_at':now,'run_id':run_id})
    if f.get('memory_candidate') or f.get('promote_to_memory'):
        status='approved' if f.get('approved_by_authorized_user') else 'proposed'
        rules.append({'memory_rule_id':hid('memory',pid,i,f.get('comment')),'rule_key':f.get('rule_key') or hid('rule_key',pid,i),'trade':f.get('trade'),'market':f.get('market') or project.get('market'),'status':status,'rule_type':f.get('rule_type','calibration'),'content':{'comment':f.get('comment') or f.get('calibration_note'),'source_feedback_id':fid,'project_specific':status!='approved'},'source':'reviewer_feedback','effective_at':f.get('effective_at'),'created_at':now,'updated_at':now,'run_id':run_id})
audit=[{'audit_log_id':hid(run_id,'feedback_memory',pid),'project_id':pid,'entity_type':'reviewer_feedback','entity_id':run_id,'action':'curate_feedback_memory','actor':payload.get('requested_by') or 'reviewer','details':{'feedback_count':len(feedback),'memory_rule_count':len(rules),'no_model_training':True},'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'reviewer_feedback':feedback,'memory_rules':rules,'audit_logs':audit,'blocked':False,'policy':'Learning is via curated memory/reference/rule records only; no model training or fine-tuning.'}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2)); Path(f'/tmp/curate-feedback-memory_feedback_{run_id}.json').write_text(json.dumps(feedback)); Path(f'/tmp/curate-feedback-memory_rules_{run_id}.json').write_text(json.dumps(rules)); Path(f'/tmp/curate-feedback-memory_audit_{run_id}.json').write_text(json.dumps(audit))
print(json.dumps({'event':'stage_complete','skill':'curate-feedback-memory','run_id':run_id,'feedback':len(feedback),'rules':len(rules)}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_reviewer_feedback --conflict "feedback_id" --run-id "${RUN_ID}" --records "$(cat /tmp/curate-feedback-memory_feedback_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_memories_rules --conflict "memory_rule_id" --run-id "${RUN_ID}" --records "$(cat /tmp/curate-feedback-memory_rules_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/curate-feedback-memory_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: curate-feedback-memory complete"
