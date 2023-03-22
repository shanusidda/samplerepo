#! /usr/bin/env bash

set -eo pipefail

GITHUB_WORKFLOW_URL=$(curl -sH "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}" | \
  jq -r '.workflow_url')

for i in $(seq 1 60); do
  RUNS=$(curl -sH "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${GITHUB_WORKFLOW_URL}/runs?per_page=5" | \
    jq -r '.workflow_runs[] | select(.status == "in_progress").id' | \
    wc -l)
  if [[ "${RUNS}" -le 1 ]]; then
    break
  else
    if [[ ${i} -ge 60 ]]; then
      echo "Other runs did not finish in time, exiting this run with a broken pipeline"
      exit 1
    fi
    echo "Pipeline is already running waiting 10 seconds..."
    sleep 10
  fi
done
