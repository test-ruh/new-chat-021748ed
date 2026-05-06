#!/usr/bin/env bash
# Auto-generated script for validate-intake
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="validate-intake"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${DATABASE_URL:?ERROR: DATABASE_URL not set}"
: "${ORG_ID:?ERROR: ORG_ID not set}"
: "${AGENT_ID:?ERROR: AGENT_ID not set}"
: "${RUN_ID:?ERROR: RUN_ID not set}"
: "${GOOGLE_MAPS_API_KEY:?ERROR: GOOGLE_MAPS_API_KEY not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/ingest-project-inputs_${RUN_ID}.json"
OUTPUT_FILE="/tmp/validate-intake_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os,json,uuid,datetime
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'; data=json.load(open(os.environ['INPUT_FILE']))
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(map(str,p))))
project=data.get('project',{}); inputs=data.get('inputs',[]); trades=[str(t).lower() for t in (project.get('trades') or [])]
supported={'paint','roofing','carpentry'}; deferred={'envelope','siding','waterproofing','masonry','misc'}
findings=[]; rfis=[]
def block(code,msg,reason):
    findings.append({'qa_finding_id':hid(run_id,'intake',code),'project_id':project.get('project_id'),'stage_run_id':run_id,'check_name':code,'result':'fail','severity':'blocker','message':msg,'metadata':{'reason':reason},'created_at':now,'run_id':run_id})
    rfis.append({'rfi_id':hid(run_id,'rfi',code),'project_id':project.get('project_id'),'stage_run_id':run_id,'question':msg,'reason':reason,'priority':'blocker','status':'open','created_at':now,'run_id':run_id})
checks=[('project_identity', project.get('project_id') and project.get('project_name')),('address', project.get('address')),('market', project.get('market')),('pricing_workbook', any(i.get('input_type')=='pricing_sheet' or 'pricing' in (i.get('file_name') or '').lower() for i in inputs)),('source_evidence', any(i.get('input_type') in ['plan','scope','report','photo','note'] for i in inputs))]
for code,ok in checks:
    if not ok: block(code,f'Missing or unresolved {code.replace("_"," ")}.','Required before reliable ECC estimating can continue.')
if not trades: block('trades','No trade list was provided.','The workflow needs declared trades to classify and price scope.')
for t in trades:
    if t in deferred: block('deferred_trade_'+t,f'{t} is optional/deferred Phase 2/1.5 and not enabled.','Enable only after approved takeoff and pricing mappings exist.')
    elif t not in supported: block('unsupported_trade_'+t,f'Unsupported trade requested: {t}.','Phase 1 supports paint, roofing, and carpentry.')
status={'project_id':project.get('project_id'),'blocked':bool(rfis),'blocker_count':len(rfis),'supported_trades':[t for t in trades if t in supported],'checklist':{c:bool(ok) for c,ok in checks}}
audit=[{'audit_log_id':hid(run_id,'validate',project.get('project_id')),'project_id':project.get('project_id'),'entity_type':'stage_run','entity_id':run_id,'action':'validate_intake','actor':'system','details':status,'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'inputs':inputs,'intake_status':status,'qa_findings':findings,'rfis':rfis,'audit_logs':audit,'blocked':bool(rfis)}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2))
for s,r in [('qa',findings),('rfis',rfis),('audit',audit)]: Path(f'/tmp/validate-intake_{s}_{run_id}.json').write_text(json.dumps(r))
print(json.dumps({'event':'stage_complete','skill':'validate-intake','run_id':run_id,'blocked':bool(rfis),'blockers':len(rfis)}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_qa_findings --conflict "qa_finding_id" --run-id "${RUN_ID}" --records "$(cat /tmp/validate-intake_qa_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_rfis --conflict "rfi_id" --run-id "${RUN_ID}" --records "$(cat /tmp/validate-intake_rfis_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/validate-intake_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: validate-intake complete"
