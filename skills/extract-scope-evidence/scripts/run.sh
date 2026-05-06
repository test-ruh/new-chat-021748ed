#!/usr/bin/env bash
# Auto-generated script for extract-scope-evidence
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="extract-scope-evidence"
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
INPUT_FILE="/tmp/validate-intake_${RUN_ID}.json"
OUTPUT_FILE="/tmp/extract-scope-evidence_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os,json,uuid,datetime,re
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'; data=json.load(open(os.environ['INPUT_FILE']))
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(map(str,p))))
project=data.get('project',{}); trades=data.get('intake_status',{}).get('supported_trades') or project.get('trades') or []
scope=[]; evidence=[]; gaps=[]
for item in data.get('inputs',[]):
    name=(item.get('file_name') or item.get('uri') or '').lower(); typ=item.get('input_type') or 'source'
    trade='paint' if any(x in name for x in ['paint','coating']) else 'roofing' if any(x in name for x in ['roof','eagleview','shingle']) else 'carpentry' if any(x in name for x in ['carp','trim','fascia','soffit']) else (trades[0] if trades else 'unclassified')
    ev=hid(run_id,'evidence',item.get('input_id'))
    evidence.append({'evidence_ref_id':ev,'project_id':project.get('project_id'),'input_id':item.get('input_id'),'source_system':item.get('source_system'),'source_ref':{'uri':item.get('uri'),'file_name':item.get('file_name'),'input_type':typ},'metadata':{'classification_trade':trade,'model_provider':os.environ.get('PRIMARY_MODEL_PROVIDER','anthropic'),'no_training':True},'created_at':now,'run_id':run_id})
    m=re.search(r'(\d+(?:\.\d+)?)\s*(sq|sf|lf|ea|squares?)',name); qty=float(m.group(1)) if m else None; unit=m.group(2).upper() if m else None; conf=0.72 if m else 0.45
    sid=hid(run_id,'scope',item.get('input_id'),trade)
    scope.append({'scope_item_id':sid,'project_id':project.get('project_id'),'pipeline_run_id':project.get('current_pipeline_run_id') or run_id,'stage_run_id':run_id,'trade':trade,'category':typ,'description':f'Potential {trade} scope from {item.get("file_name") or item.get("uri")}', 'quantity':qty,'unit':unit,'confidence':conf,'source_refs':[ev],'metadata':{'requires_reviewer_confirmation':conf<0.6,'ocr_sketch_parsing':'placeholder_or_provider_runtime'},'created_at':now,'updated_at':now,'run_id':run_id})
    if conf<0.6: gaps.append({'gap_id':hid(run_id,'gap',sid),'trade':trade,'question':f'Confirm dimensions/scope for {trade} evidence in {item.get("file_name")}.','source_refs':[ev],'priority':'medium'})
audit=[{'audit_log_id':hid(run_id,'extract',project.get('project_id')),'project_id':project.get('project_id'),'entity_type':'stage_run','entity_id':run_id,'action':'extract_scope_evidence','actor':'system','details':{'scope_item_count':len(scope),'evidence_ref_count':len(evidence),'gap_count':len(gaps),'model_metadata_redacted':True},'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'scope_items':scope,'evidence_refs':evidence,'gap_candidates':gaps,'audit_logs':audit,'blocked':False}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2))
for s,r in [('scope',scope),('evidence',evidence),('audit',audit)]: Path(f'/tmp/extract-scope-evidence_{s}_{run_id}.json').write_text(json.dumps(r))
print(json.dumps({'event':'stage_complete','skill':'extract-scope-evidence','run_id':run_id,'scope_items':len(scope),'gaps':len(gaps)}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_scope_items --conflict "scope_item_id" --run-id "${RUN_ID}" --records "$(cat /tmp/extract-scope-evidence_scope_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_evidence_refs --conflict "evidence_ref_id" --run-id "${RUN_ID}" --records "$(cat /tmp/extract-scope-evidence_evidence_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/extract-scope-evidence_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: extract-scope-evidence complete"
