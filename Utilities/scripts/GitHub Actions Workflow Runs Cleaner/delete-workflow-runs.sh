#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Repository and workflows to process
REPO="ita-social-projects/SpaceToStudy-DevOps"
WORKFLOWS="Backup MongoDB Atlas" # Specify workflow names separated by commas

# Dry-run mode
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# Function to log messages
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

log "Fetching list of workflow runs..."

# Convert WORKFLOWS into an array
IFS=',' read -ra WORKFLOW_NAMES <<< "$WORKFLOWS"

for WORKFLOW_NAME in "${WORKFLOW_NAMES[@]}"; do
  WORKFLOW_NAME="$(echo "$WORKFLOW_NAME" | xargs)" # trim spaces
  log "Processing workflow: $WORKFLOW_NAME"

  # Fetch run IDs for the current workflow
  query=".workflow_runs[] | select(.name == \"$WORKFLOW_NAME\") | .id"
  run_ids=$(gh api -X GET "repos/$REPO/actions/runs" --paginate -q "$query")

  if [[ -z "$run_ids" ]]; then
    log "No runs found for workflow '$WORKFLOW_NAME'."
    continue
  fi

  log "Found $(echo "$run_ids" | wc -l) runs to delete for workflow '$WORKFLOW_NAME'."

  # Delete each run
  for run_id in $run_ids; do
    if [[ "$DRY_RUN" == true ]]; then
      log "[DRY-RUN] Would delete run ID: $run_id"
    else
      log "Deleting run ID: $run_id"
      gh api -X DELETE "repos/$REPO/actions/runs/$run_id" || log "Failed to delete run ID: $run_id"
    fi
  done
done

log "Workflow run deletion completed."