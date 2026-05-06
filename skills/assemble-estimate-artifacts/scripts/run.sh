#!/usr/bin/env bash
# Auto-generated script for assemble-estimate-artifacts
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="assemble-estimate-artifacts"
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
: "${SHAREPOINT_TENANT_ID:?ERROR: SHAREPOINT_TENANT_ID not set}"
: "${SHAREPOINT_SITE_ID:?ERROR: SHAREPOINT_SITE_ID not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/generate-qa-rfi-risk-package_${RUN_ID}.json"
OUTPUT_FILE="/tmp/assemble-estimate-artifacts_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os,json,uuid,datetime,zipfile,csv
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'; data=json.load(open(os.environ['INPUT_FILE']))
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(map(str,p))))
project=data.get('project',{}); pid=project.get('project_id'); base=Path('/tmp')/f'ecc_package_{run_id}'; base.mkdir(exist_ok=True)
for name,key in [('estimate_lines.json','estimate_lines'),('rfi_log.json','rfis'),('qa_checklist.json','qa_findings'),('assumptions_exclusions.json','assumptions'),('risks_alternates.json','risks')]: (base/name).write_text(json.dumps(data.get(key,[]),indent=2))
with open(base/'estimate_lines.csv','w',newline='') as f:
    fields=['trade','sheet_tab','line_code','description','quantity','unit','unit_price','extended_price']; w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); [w.writerow({k:l.get(k) for k in fields}) for l in data.get('estimate_lines',[])]
(base/'draft_estimate.xlsx').write_text('PLACEHOLDER: copy canonical ECC workbook and write only approved ranges.\n')
(base/'review_summary.pdf').write_text('PLACEHOLDER: reviewer summary for RFIs, QA, assumptions, risks, alternates, and sub bids.\n')
zip_path=Path('/tmp')/f'ecc_estimate_package_{run_id}.zip'
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as z:
    for p in base.iterdir(): z.write(p,p.name)
artifacts=[]
for typ,p in [('estimate_xlsx',base/'draft_estimate.xlsx'),('rfi_log',base/'rfi_log.json'),('qa_checklist',base/'qa_checklist.json'),('assumptions',base/'assumptions_exclusions.json'),('risks',base/'risks_alternates.json'),('sub_bid_package',base/'review_summary.pdf'),('json_export',base/'estimate_lines.json'),('zip_bundle',zip_path)]:
    artifacts.append({'artifact_id':hid(run_id,typ),'project_id':pid,'pipeline_run_id':project.get('current_pipeline_run_id') or run_id,'stage_run_id':run_id,'artifact_type':typ,'uri':str(p),'version':1,'status':'draft','metadata':{'sharepoint_upload_pending':True,'file_name':p.name,'blocked_input':data.get('blocked',False)},'created_at':now,'run_id':run_id})
notification={'subject':'ECC draft estimate package ready for review' if not data.get('blocked') else 'ECC draft package assembled with blockers','body':'Review the XLSX, RFIs, QA checklist, assumptions/exclusions, risks/alternates, sub bid package, audit log, and revision diff before approval.','artifact_uris':[a['uri'] for a in artifacts]}
audit=[{'audit_log_id':hid(run_id,'assemble',pid),'project_id':pid,'entity_type':'stage_run','entity_id':run_id,'action':'assemble_estimate_artifacts','actor':'system','details':{'artifact_count':len(artifacts),'notification':notification,'secrets_redacted':True},'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'artifacts':artifacts,'notification':notification,'audit_logs':audit,'blocked':False}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2)); Path(f'/tmp/assemble-estimate-artifacts_artifacts_{run_id}.json').write_text(json.dumps(artifacts)); Path(f'/tmp/assemble-estimate-artifacts_audit_{run_id}.json').write_text(json.dumps(audit))
print(json.dumps({'event':'stage_complete','skill':'assemble-estimate-artifacts','run_id':run_id,'artifacts':len(artifacts)}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_artifacts --conflict "artifact_id" --run-id "${RUN_ID}" --records "$(cat /tmp/assemble-estimate-artifacts_artifacts_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/assemble-estimate-artifacts_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: assemble-estimate-artifacts complete"
