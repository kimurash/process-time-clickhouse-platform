create database if not exists otel;

create table if not exists otel.pull_requests (
  repository  String,
  number      UInt32,
  head_branch String,
  created_at  DateTime64(3),
  merged_at   Nullable(DateTime64(3)),
  url         String
)
engine = ReplacingMergeTree
order by (repository, number);
