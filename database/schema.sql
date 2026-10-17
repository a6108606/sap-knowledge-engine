-- SAP Knowledge Engine: initial SQLite schema (v1)
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS sources (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  origin TEXT,
  source_type TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS ingestion_runs (
  id TEXT PRIMARY KEY,
  source_id TEXT NOT NULL REFERENCES sources(id),
  collected_at TEXT NOT NULL,
  collector_version TEXT,
  sap_product TEXT, edition TEXT, release TEXT,
  checksum_sha256 TEXT, record_count INTEGER,
  manifest_json TEXT
);
CREATE TABLE IF NOT EXISTS objects (
  id INTEGER PRIMARY KEY,
  sap_product TEXT NOT NULL,
  edition TEXT NOT NULL DEFAULT '',
  release TEXT NOT NULL DEFAULT '',
  system_namespace TEXT NOT NULL DEFAULT '',
  object_type TEXT NOT NULL,
  technical_name TEXT NOT NULL,
  canonical_status TEXT NOT NULL DEFAULT 'candidate',
  UNIQUE (sap_product,edition,release,system_namespace,object_type,technical_name)
);
CREATE INDEX IF NOT EXISTS idx_objects_name ON objects(technical_name,object_type);
CREATE TABLE IF NOT EXISTS object_texts (
  object_id INTEGER NOT NULL REFERENCES objects(id),
  lang TEXT NOT NULL,
  description TEXT NOT NULL,
  PRIMARY KEY(object_id,lang)
);
CREATE TABLE IF NOT EXISTS fields (
  id INTEGER PRIMARY KEY,
  owner_object_id INTEGER NOT NULL REFERENCES objects(id),
  field_name TEXT NOT NULL,
  ordinal INTEGER,
  datatype TEXT, length INTEGER, decimals INTEGER,
  is_key INTEGER NOT NULL DEFAULT 0 CHECK(is_key IN (0,1)),
  data_element TEXT, domain_name TEXT,
  UNIQUE(owner_object_id,field_name)
);
CREATE INDEX IF NOT EXISTS idx_fields_owner ON fields(owner_object_id,ordinal);
CREATE TABLE IF NOT EXISTS relations (
  id INTEGER PRIMARY KEY,
  source_object_id INTEGER NOT NULL REFERENCES objects(id),
  target_object_id INTEGER NOT NULL REFERENCES objects(id),
  relation_type TEXT NOT NULL,
  join_condition TEXT,
  verification_status TEXT NOT NULL DEFAULT 'candidate',
  UNIQUE(source_object_id,target_object_id,relation_type,join_condition)
);
CREATE INDEX IF NOT EXISTS idx_relations_source ON relations(source_object_id,relation_type);
CREATE INDEX IF NOT EXISTS idx_relations_target ON relations(target_object_id,relation_type);
CREATE TABLE IF NOT EXISTS assertions (
  id INTEGER PRIMARY KEY,
  run_id TEXT NOT NULL REFERENCES ingestion_runs(id),
  source_record_key TEXT NOT NULL,
  subject_object_id INTEGER REFERENCES objects(id),
  predicate TEXT NOT NULL,
  value_json TEXT,
  evidence_pointer TEXT,
  verification_status TEXT NOT NULL DEFAULT 'candidate',
  UNIQUE(run_id,source_record_key,predicate,value_json)
);
CREATE INDEX IF NOT EXISTS idx_assertions_subject ON assertions(subject_object_id,predicate);
CREATE TABLE IF NOT EXISTS conflicts (
  id INTEGER PRIMARY KEY,
  object_id INTEGER REFERENCES objects(id),
  attribute TEXT NOT NULL,
  competing_assertion_ids_json TEXT NOT NULL,
  review_status TEXT NOT NULL DEFAULT 'open',
  resolution_note TEXT
);
CREATE TABLE IF NOT EXISTS classifications (
  object_id INTEGER NOT NULL REFERENCES objects(id),
  axis TEXT NOT NULL,
  label TEXT NOT NULL,
  PRIMARY KEY(object_id,axis,label)
);
-- External-content FTS. Application rebuilds this after consolidated loads.
CREATE VIRTUAL TABLE IF NOT EXISTS object_fts USING fts5(
  technical_name, description,
  content=''
);
