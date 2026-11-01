create materialized view if not exists otel.process_time_mv
refresh every 1 hour
engine = MergeTree
order by (repository, number)
as
with session_branch as (
  select distinct
    LogAttributes['session.id']         as session_id,
    LogAttributes['vcs.ref.head.name']  as head_branch
  from otel.otel_logs
  where LogAttributes['vcs.ref.head.name'] != ''
)
select
  pr.repository,
  pr.number,
  min(l.Timestamp)                                        as first_claude_event,
  pr.merged_at,
  dateDiff('second', min(l.Timestamp), pr.merged_at)      as process_time_seconds
from otel.pull_requests pr final
join session_branch sb on sb.head_branch = pr.head_branch
join otel.otel_logs  l  on l.LogAttributes['session.id'] = sb.session_id
where pr.merged_at is not null
group by pr.repository, pr.number, pr.merged_at;
