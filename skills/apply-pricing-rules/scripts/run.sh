#!/usr/bin/env bash
# Auto-generated script for apply-pricing-rules
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="apply-pricing-rules"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${DATABASE_URL:?ERROR: DATABASE_URL not set}"
: "${ORG_ID:?ERROR: ORG_ID not set}"
: "${AGENT_ID:?ERROR: AGENT_ID not set}"
: "${RUN_ID:?ERROR: RUN_ID not set}"
: "${SHAREPOINT_CLIENT_ID:?ERROR: SHAREPOINT_CLIENT_ID not set}"
: "${SHAREPOINT_CLIENT_SECRET:?ERROR: SHAREPOINT_CLIENT_SECRET not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/extract-scope-evidence_${RUN_ID}.json"
OUTPUT_FILE="/tmp/apply-pricing-rules_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os,json,uuid,datetime
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'; data=json.load(open(os.environ['INPUT_FILE']))
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(map(str,p))))
project=data.get('project',{}); rates={'paint':3.25,'roofing':475.00,'carpentry':85.00}; default_units={'paint':'SF','roofing':'SQ','carpentry':'LF'}
lines=[]; gaps=[]
for n,s in enumerate(data.get('scope_items',[]),1):
    trade=(s.get('trade') or 'unclassified').lower(); qty=s.get('quantity') or 0; unit=s.get('unit') or default_units.get(trade,'EA'); unit_price=rates.get(trade,0.0)
    if not qty or not unit_price:
        gaps.append({'qa_finding_id':hid(run_id,'pricing_gap',s.get('scope_item_id')),'project_id':project.get('project_id'),'stage_run_id':run_id,'check_name':'pricing_or_quantity_gap','result':'warning','severity':'medium','message':f'Missing quantity or approved rate for {s.get("description")}.','metadata':{'scope_item_id':s.get('scope_item_id'),'trade':trade},'created_at':now,'run_id':run_id})
    lines.append({'estimate_line_id':hid(run_id,'line',n,s.get('scope_item_id')),'project_id':project.get('project_id'),'pipeline_run_id':project.get('current_pipeline_run_id') or run_id,'stage_run_id':run_id,'trade':trade,'sheet_tab':trade.title() if trade in rates else 'Misc','line_code':f'{trade[:3].upper()}-{n:03d}','description':s.get('description'),'quantity':qty,'unit':unit,'unit_price':unit_price,'extended_price':round(float(qty)*unit_price,2),'pricing_config_id':os.environ.get('PRICING_CONFIG_ID') or 'unresolved-runtime-config','source_refs':s.get('source_refs',[]),'metadata':{'workbook_mapping':'configured_runtime_required','market':project.get('market'),'approved_memory_rules':[],'read_only_references':['NetSuite','BlueCollar']},'created_at':now,'updated_at':now,'run_id':run_id})
audit=[{'audit_log_id':hid(run_id,'pricing',project.get('project_id')),'project_id':project.get('project_id'),'entity_type':'stage_run','entity_id':run_id,'action':'apply_pricing_rules','actor':'system','details':{'line_count':len(lines),'pricing_gap_count':len(gaps),'total':round(sum(l['extended_price'] for l in lines),2),'secrets_redacted':True},'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'estimate_lines':lines,'pricing_gaps':gaps,'audit_logs':audit,'summary':{'total':round(sum(l['extended_price'] for l in lines),2)},'blocked':False}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2))
for s,r in [('lines',lines),('qa',gaps),('audit',audit)]: Path(f'/tmp/apply-pricing-rules_{s}_{run_id}.json').write_text(json.dumps(r))
print(json.dumps({'event':'stage_complete','skill':'apply-pricing-rules','run_id':run_id,'estimate_lines':len(lines),'total':result['summary']['total']}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_estimate_lines --conflict "estimate_line_id" --run-id "${RUN_ID}" --records "$(cat /tmp/apply-pricing-rules_lines_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_qa_findings --conflict "qa_finding_id" --run-id "${RUN_ID}" --records "$(cat /tmp/apply-pricing-rules_qa_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/apply-pricing-rules_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: apply-pricing-rules complete"
