# Technical ingestion and consolidation

1. Ingest each source independently as immutable batches: `source_id`, `run_id`, `origin`, `collector_version`, `sap_product`, `edition`, `release`, `hash`, `record_count`.
2. Normalize into source-preserving JSONL assertions: `subject`, `predicate`, `value_or_target`, `source_id`, `source_record_key`, `evidence_pointer`, `observed_at`.
3. Resolve identities using `product + edition + release + type + technical_name + optional system_namespace`.
4. Consolidate using field-specific precedence and verification; retain conflicting claims in a review queue. Never last-write-wins.
5. Materialize SQLite in a temporary file and publish after integrity checks.

Relationship types: `FOREIGN_KEY_TO`, `CDS_ASSOCIATED_WITH`, `DEPENDS_ON`, `BUSINESS_EQUIVALENT_TO`. Identical field names alone do not imply joins. Keep cross-release objects separate. Preserve language-specific descriptions and customizing classifications. Quality gates: deterministic rebuild, referential integrity, conflict reporting, FTS synchronization and bounded graph traversal.
