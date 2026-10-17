# SQLite technical architecture — V1

## Data flow
Independent source adapters -> immutable source snapshots -> normalized JSONL assertions -> identity resolver -> conflict-aware consolidation -> SQLite build -> API / search / LLM tools.

Store raw snapshots and normalized assertions separately from the serving database. Each ingestion batch has a manifest with source ID, run ID, timestamp, collector version, SAP product/edition/release, record count and checksum. Build SQLite transactionally from validated snapshots; publish new database atomically.

## Logical data model

| Table | Role |
|---|---|
| sources | Source catalog |
| ingestion_runs | Batch manifests and hashes |
| objects | Version-aware SAP technical objects |
| object_texts | Language-specific descriptions |
| fields | Fields owned by an object, with technical type |
| relations | Typed edges, join expression and verification |
| assertions | Source-specific claims, preserved separately |
| conflicts | Incompatible source claims requiring review |
| classifications | Component and business-role tags |
| object_fts | FTS5 index of technical names and descriptions |

Canonical object identity: `sap_product + edition + release + system_namespace + object_type + technical_name`. Do not merge ECC and S/4HANA versions merely because object names match.

Object types include TABLE, STRUCTURE, VIEW, CDS_VIEW, CDS_VIEW_ENTITY, DATA_ELEMENT, DOMAIN, API. Relation types include FOREIGN_KEY_TO, CDS_ASSOCIATED_WITH, DEPENDS_ON, BUSINESS_EQUIVALENT_TO. The latter does not imply a direct physical SQL dependency.

## Query strategy
- Exact object lookup via unique composite index.
- Field lookup via owner/name index.
- FTS5 for labels and technical descriptions; rank exact matches above FTS.
- Join paths and CDS transitive dependencies via bounded recursive CTEs on relations.
- Every answer can resolve source-specific evidence through assertions and ingestion_runs.
- Graph or vector services may be added later but are unnecessary for initial target scale.

## Performance & operations
Use Python sqlite3, foreign_keys=ON and transactional bulk imports. Index source and target on edges; index owner/name on fields. Use WAL for concurrent local reads, not for an active database on network storage. Keep active database on an SSD and snapshots/backups on NAS. Optimize only after query-plan benchmarks.

## Quality gates
Stable rebuild from identical inputs; no orphan records or untracked assertions; conflicts remain visible; no accidental release mixing; FTS reflects canonical objects; sampled relation traversals return typed, verifiable paths. Excel and CSV are derived reports only.
