# SAP Knowledge Engine

## Architecture
Collect independently from SAP DDIC, SAP CDS, LeanX, API metadata and manual exports; normalize source records into JSONL; reconcile duplicates/conflicts; materialize a version-aware SQLite knowledge catalog with FTS5 and typed graph relations.

Pipeline: `collectors -> raw/<source>/<run> -> normalized JSONL -> consolidation -> SQLite -> local LLM tools`.

Primary store: SQLite. Excel/CSV are review/import/export formats, not the source of truth. See [database specification](database/ARCHITECTURE.md) and [SQL schema](database/schema.sql).

## Modules
MM, PP, QM, LE, SD, FI, CO, PP/DS, APO and cross-functional/customizing objects. The 10,000-table target is indicative, not a hard cap.

## Directories
- `sources/`: source registry
- `collectors/`: isolated adapters
- `schemas/`: exchange formats
- `normalization/`: source mappings (planned)
- `consolidation/`: identity and conflict rules
- `database/`: SQLite model, indexes and FTS
- `docs/`: ingestion and build specification

Generated data stays outside Git in `raw/`, `normalized/`, `curated/`, `builds/` and `reports/`.
