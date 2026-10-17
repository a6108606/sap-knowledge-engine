# Collectors

Separate adapters per source: `sap_ddic/`, `sap_cds/`, `leanx/`, `sap_api_hub/`, `manual/`. Emit source-native records and `manifest.json` under `raw/<source>/<run>/`. Include stable source record keys, hashes and resumable progress. Never write directly to canonical SQLite objects.
