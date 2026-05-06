# Workflow — End-to-End Process Flow

## Workflow Steps

1. **data-writer** → data-writer
2. **ingest_project_inputs** → ingest-project-inputs
3. **validate_intake** → validate-intake (depends on ingest_project_inputs)
4. **intake_blocker_notice** → native-tool: message (depends on validate_intake)
5. **extract_scope_evidence** → extract-scope-evidence (depends on validate_intake)
6. **apply_pricing_rules** → apply-pricing-rules (depends on extract_scope_evidence)
7. **generate_qa_rfi_risk_package** → generate-qa-rfi-risk-package (depends on apply_pricing_rules)
8. **qa_blocker_notice** → native-tool: message (depends on generate_qa_rfi_risk_package)
9. **assemble_estimate_artifacts** → assemble-estimate-artifacts (depends on generate_qa_rfi_risk_package)
10. **completion_notice** → native-tool: message (depends on assemble_estimate_artifacts)
11. **manage_rerun_and_diff** → manage-rerun-and-diff
12. **curate_feedback_memory** → curate-feedback-memory (depends on manage_rerun_and_diff)

## Diagram

```
data-writer → ingest_project_inputs → validate_intake → intake_blocker_notice → extract_scope_evidence → apply_pricing_rules → generate_qa_rfi_risk_package → qa_blocker_notice → assemble_estimate_artifacts → completion_notice → manage_rerun_and_diff → curate_feedback_memory
```
