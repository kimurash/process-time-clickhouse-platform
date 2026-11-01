#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

repo="${1:?usage: $0 owner/repo}"

ch() {
  docker compose exec -T clickhouse clickhouse-client --multiquery --date_time_input_format=best_effort "$@"
}

ch < sql/pull_requests.sql

gh api --paginate "repos/${repo}/pulls?state=all&per_page=100" \
  | jq -r --arg repo "$repo" '
      .[] | [$repo, .number, .head.ref, .created_at, (.merged_at // "\\N"), .html_url] | @csv' \
  | ch --query "insert into otel.pull_requests format CSV"

ch --query "select count() as pull_requests from otel.pull_requests final where repository = '${repo}'"
