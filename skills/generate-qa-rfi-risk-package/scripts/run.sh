#!/usr/bin/env bash
# Auto-generated script for generate-qa-rfi-risk-package
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="generate-qa-rfi-risk-package"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${DATABASE_URL:?ERROR: DATABASE_URL not set}"
: "${ORG_ID:?ERROR: ORG_ID not set}"
: "${AGENT_ID:?ERROR: AGENT_ID not set}"
: "${RUN_ID:?ERROR: RUN_ID not set}"
: "${ANTHROPIC_API_KEY:?ERROR: ANTHROPIC_API_KEY not set}"
: "${OPENAI_API_KEY:?ERROR: OPENAI_API_KEY not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/apply-pricing-rules_${RUN_ID}.json"
OUTPUT_FILE="/tmp/generate-qa-rfi-risk-package_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os,json,uuid,datetime
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'; data=json.load(open(os.environ['INPUT_FILE']))
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(map(str,p))))
project=data.get('project',{}); lines=data.get('estimate_lines',[]); qa=list(data.get('pricing_gaps',[])); rfis=[]; assumptions=[]; risks=[]
for l in lines:
    if not l.get('source_refs'):
        qa.append({'qa_finding_id':hid(run_id,'no_source',l.get('estimate_line_id')),'project_id':project.get('project_id'),'stage_run_id':run_id,'check_name':'line_source_refs','result':'fail','severity':'blocker','message':'Estimate line lacks source reference.','metadata':{'estimate_line_id':l.get('estimate_line_id')},'created_at':now,'run_id':run_id})
    if not l.get('quantity') or not l.get('unit_price'):
        rfis.append({'rfi_id':hid(run_id,'rfi_line',l.get('estimate_line_id')),'project_id':project.get('project_id'),'stage_run_id':run_id,'question':f'Confirm quantity/pricing basis for {l.get("description")}.','reason':'Missing quantity, unit price, or approved pricing mapping.','priority':'blocker' if not l.get('quantity') else 'high','status':'open','created_at':now,'run_id':run_id})
for trade in sorted({l.get('trade') or 'unclassified' for l in lines}):
    assumptions.append({'assumption_id':hid(run_id,'assumption',trade),'project_id':project.get('project_id'),'stage_run_id':run_id,'category':'scope','text':f'Draft {trade} estimate is based only on cited source evidence and approved ECC pricing references available at run time.','status':'active','metadata':{'trade':trade},'created_at':now,'updated_at':now,'run_id':run_id})
risks.append({'risk_id':hid(run_id,'risk','calibration'),'project_id':project.get('project_id'),'stage_run_id':run_id,'risk_type':'calibration','severity':'medium','description':'Accuracy depends on market calibration, complete source evidence, and current pricing workbook mappings.','impact':'Potential variance versus Darrow review outside established/calibrated markets.','mitigation':'Reviewer QA and RFIs before final use.','metadata':{},'created_at':now,'updated_at':now,'run_id':run_id})
blocked=any(x.get('severity')=='blocker' or x.get('priority')=='blocker' for x in qa+rfis)
audit=[{'audit_log_id':hid(run_id,'qa',project.get('project_id')),'project_id':project.get('project_id'),'entity_type':'stage_run','entity_id':run_id,'action':'generate_qa_rfi_risk_package','actor':'system','details':{'qa_count':len(qa),'rfi_count':len(rfis),'assumption_count':len(assumptions),'risk_count':len(risks),'blocked':blocked},'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'estimate_lines':lines,'qa_findings':qa,'rfis':rfis,'assumptions':assumptions,'risks':risks,'audit_logs':audit,'blocked':blocked,'review_summary':{'blocker_count':sum(1 for x in qa+rfis if x.get('severity')=='blocker' or x.get('priority')=='blocker')}}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2))
for s,r in [('qa',qa),('rfis',rfis),('assumptions',assumptions),('risks',risks),('audit',audit)]: Path(f'/tmp/generate-qa-rfi-risk-package_{s}_{run_id}.json').write_text(json.dumps(r))
print(json.dumps({'event':'stage_complete','skill':'generate-qa-rfi-risk-package','run_id':run_id,'blocked':blocked,'rfis':len(rfis)}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_qa_findings --conflict "qa_finding_id" --run-id "${RUN_ID}" --records "$(cat /tmp/generate-qa-rfi-risk-package_qa_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_rfis --conflict "rfi_id" --run-id "${RUN_ID}" --records "$(cat /tmp/generate-qa-rfi-risk-package_rfis_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_assumptions --conflict "assumption_id" --run-id "${RUN_ID}" --records "$(cat /tmp/generate-qa-rfi-risk-package_assumptions_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_risks --conflict "risk_id" --run-id "${RUN_ID}" --records "$(cat /tmp/generate-qa-rfi-risk-package_risks_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/generate-qa-rfi-risk-package_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: generate-qa-rfi-risk-package complete"
