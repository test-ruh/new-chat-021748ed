#!/usr/bin/env bash
# Auto-generated script for ingest-project-inputs
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="ingest-project-inputs"
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
: "${SHAREPOINT_ROOT_FOLDER_ID:?ERROR: SHAREPOINT_ROOT_FOLDER_ID not set}"
: "${COMPANYCAM_API_KEY:?ERROR: COMPANYCAM_API_KEY not set}"
: "${COMPANYCAM_WEBHOOK_SECRET:?ERROR: COMPANYCAM_WEBHOOK_SECRET not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/payload_${RUN_ID}.json"
OUTPUT_FILE="/tmp/ingest-project-inputs_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import os, json, hashlib, uuid, datetime
from pathlib import Path
run_id=os.environ['RUN_ID']; now=datetime.datetime.utcnow().isoformat()+'Z'
payload=json.load(open(os.environ.get('INPUT_FILE') or f'/tmp/payload_{run_id}.json')) if Path(os.environ.get('INPUT_FILE') or f'/tmp/payload_{run_id}.json').exists() else {}
def hid(*p): return str(uuid.uuid5(uuid.NAMESPACE_URL,'|'.join(str(x) for x in p if x is not None)))
project_hint=payload.get('project_id') or payload.get('external_project_key') or payload.get('project') or 'unmapped'
project_id=payload.get('project_id') or hid(os.environ['ORG_ID'], project_hint)
project={'project_id':project_id,'external_project_key':payload.get('external_project_key') or str(project_hint),'project_name':payload.get('project_name') or payload.get('name') or f'ECC Project {project_hint}','market':payload.get('market'),'address':payload.get('address'),'trades':payload.get('trades') or [],'status':'intake','current_pipeline_run_id':payload.get('pipeline_run_id') or run_id,'created_at':now,'updated_at':now,'run_id':run_id}
inputs=[]
for i,item in enumerate(payload.get('inputs') or payload.get('files') or []):
    uri=item.get('uri') or item.get('webUrl') or item.get('id') or f'manual:{i}'
    name=item.get('file_name') or item.get('name') or uri.rsplit('/',1)[-1]
    h=item.get('content_hash') or hashlib.sha256((uri+json.dumps(item,sort_keys=True)).encode()).hexdigest()
    source=item.get('source_system') or item.get('source') or ('CompanyCam' if 'companycam' in uri.lower() else 'SharePoint')
    typ=item.get('input_type') or ('photo' if name.lower().endswith(('.jpg','.jpeg','.png','.webp')) else 'report' if 'eagleview' in name.lower() else 'plan' if name.lower().endswith('.pdf') else 'note')
    inputs.append({'input_id':hid(project_id,source,uri,h),'project_id':project_id,'source_system':source,'input_type':typ,'uri':uri,'file_name':name,'content_hash':h,'metadata':{'raw':item,'trigger_type':payload.get('trigger_type')},'received_at':now,'run_id':run_id})
connectors=[{'connector_id':hid(c),'connector_name':c,'status':'configured','metadata':{'checked_at':now,'secrets_redacted':True},'run_id':run_id} for c in ['sharepoint','companycam']]
if os.environ.get('EAGLEVIEW_API_KEY') or any(i['source_system'].lower()=='eagleview' for i in inputs): connectors.append({'connector_id':hid('eagleview'),'connector_name':'eagleview','status':'configured_or_file_ingest','metadata':{'checked_at':now},'run_id':run_id})
audit=[{'audit_log_id':hid(run_id,'ingest',project_id),'project_id':project_id,'entity_type':'stage_run','entity_id':run_id,'action':'ingest_project_inputs','actor':'system','details':{'input_count':len(inputs),'sources':sorted({i['source_system'] for i in inputs}),'secrets_redacted':True},'created_at':now,'run_id':run_id}]
result={'run_id':run_id,'project':project,'inputs':inputs,'connectors':connectors,'audit_logs':audit,'blocked':False,'summary':{'input_count':len(inputs)}}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(result,indent=2))
for suffix,records in [('projects',[project]),('inputs',inputs),('connectors',connectors),('audit',audit)]: Path(f'/tmp/ingest-project-inputs_{suffix}_{run_id}.json').write_text(json.dumps(records))
print(json.dumps({'event':'stage_complete','skill':'ingest-project-inputs','run_id':run_id,'input_count':len(inputs)}))
PY
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_projects --conflict "project_id" --run-id "${RUN_ID}" --records "$(cat /tmp/ingest-project-inputs_projects_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_inputs --conflict "input_id" --run-id "${RUN_ID}" --records "$(cat /tmp/ingest-project-inputs_inputs_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_connectors --conflict "connector_id" --run-id "${RUN_ID}" --records "$(cat /tmp/ingest-project-inputs_connectors_${RUN_ID}.json)"
python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table result_audit_logs --conflict "audit_log_id" --run-id "${RUN_ID}" --records "$(cat /tmp/ingest-project-inputs_audit_${RUN_ID}.json)"

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: ingest-project-inputs complete"
