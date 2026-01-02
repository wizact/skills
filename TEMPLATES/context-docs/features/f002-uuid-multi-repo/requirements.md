# Feature Requirements: UUID Primary Keys and Multi-Repository Support

**Related**: User request | [Design](./design.md) | [Tasks](./tasks.md)
**Type**: Feature
**Priority**: High
**Created**: 2026-01-01

## Overview
Enhance code-chunker's database schema to use UUID v7 primary keys for better security and standardization, and extend storage to support multiple repositories with organization-level isolation. These changes enable distributed systems compatibility, time-ordered chunk IDs, and multi-tenant usage patterns for LLM tool developers managing code across organizations.

## Requirements

### R1: UUID v7 Primary Keys

**User Story**: As a data scientist building reproducible ML pipelines, I want chunk IDs to be UUID v7 instead of sequential integers, so that chunk references remain stable across database imports/exports and distributed systems with time-ordered benefits.

**Acceptance Criteria**:
- The `code_chunks` table shall use UUID type for the `id` column instead of BIGSERIAL
- WHEN a new chunk is saved, the system shall generate a UUID v7 value for the `id` column
- The primary key constraint shall remain as composite including the UUID `id` field
- The system shall preserve all existing indexes after migration
- IF existing data exists during migration, THEN the system shall convert BIGSERIAL values to UUID format using PostgreSQL's `uuid_generate_v7()` function
- The UUID v7 format shall provide time-ordered IDs for better B-tree index performance

### R2: Organisation Name Field

**User Story**: As an LLM tool developer managing code across multiple organizations, I want to specify an organization name when storing chunks, so that I can isolate and query chunks by organization.

**Acceptance Criteria**:
- The `code_chunks` table shall include an `organisation_name` column of type TEXT
- The `organisation_name` column shall be nullable
- WHERE `organisation_name` is NULL, the system shall treat it as the default organization (not the string "default")
- The `SaveChunks` method shall accept an optional `organisationName` parameter
- The system shall create an index on `organisation_name` for efficient filtering

### R3: Repository Name Field

**User Story**: As a DevOps engineer tracking code changes across repositories, I want to specify a repository name when storing chunks, so that chunks from different repositories are clearly separated.

**Acceptance Criteria**:
- The `code_chunks` table shall include a `repo_name` column of type TEXT NOT NULL
- The `SaveChunks` method shall accept a required `repoName` parameter
- IF `repo_name` is an empty string, THEN the system shall return a validation error
- The system shall create a composite index on `(organisation_name, repo_name, file_path)` for efficient multi-repository queries

### R4: Version Tracking per Repository

**User Story**: As an LLM tool developer storing chunks from multiple repositories, I want version numbers to be scoped per repository and file path, so that each repository maintains its own version sequence.

**Acceptance Criteria**:
- The `get_next_version()` function shall accept `p_organisation_name` and `p_repo_name` parameters in addition to `p_file_path`
- WHEN calculating the next version, the system shall use `(organisation_name, repo_name, file_path)` as the grouping key
- The version sequence shall restart at 1 for each unique `(organisation_name, repo_name, file_path)` combination
- WHERE `organisation_name` is NULL, the system shall use NULL in the version calculation (NULL-safe comparison)

### R5: Updated ChunkStorage Interface

**User Story**: As a Go developer integrating code-chunker, I want the ChunkStorage interface to support organization and repository parameters, so that I can store and query chunks with multi-repository context.

**Acceptance Criteria**:
- The `SaveChunks` method shall accept `organisationName` and `repoName` parameters (in addition to existing parameters)
- The `GetLatestChunks` method shall accept `organisationName`, `repoName`, and `filePath` parameters
- The `GetChunksByVersion` method shall accept `organisationName`, `repoName`, `filePath`, and `version` parameters
- The `GetChunksByGitHash` method shall remain unchanged (git hash is globally unique)
- The system shall maintain backward compatibility by treating empty `organisationName` as NULL (default organization)

### R6: Data Migration Safety

**User Story**: As a database administrator, I want the schema migration to preserve all existing chunk data, so that no data is lost during the UUID and multi-repository upgrade.

**Acceptance Criteria**:
- WHEN the migration runs, the system shall preserve all existing chunk data
- The system shall convert all BIGSERIAL `id` values to UUID v7 using `uuid_generate_v7()` function
- WHERE existing data has NULL `organisation_name`, the migration shall leave it as NULL (not set to "default" string)
- WHERE existing data lacks `repo_name`, the migration shall set it to "legacy" to indicate pre-migration data
- The migration shall include a rollback (`+goose Down`) that restores the original schema
- IF the rollback is executed, THEN the system shall drop UUID function and restore BIGSERIAL for `id`
- The rollback shall include warnings that it is destructive (UUID data will be lost)

## Out of Scope
- Renaming existing repositories (manual SQL updates if needed)
- Automatic detection of organization from git remote URL
- Organization-level access control or authentication
- Bulk migration tool to assign proper `repo_name` to legacy data (users can do manual SQL UPDATE)
- Cross-repository chunk deduplication
- Embedding generation or storage (remains out of scope per product.md)

## Success Criteria
1. ✅ All requirements (R1-R6) pass acceptance tests
2. ✅ Existing Go integration tests pass with updated ChunkStorage interface
3. ✅ Migration runs successfully on test database with existing data
4. ✅ No data loss during migration (verified with before/after row counts)
5. ✅ Query performance remains within 10% of current performance for `GetLatestChunks`
6. ✅ Rollback migration successfully restores original schema
7. ✅ UUID v7 generation produces time-ordered, unique identifiers

## References
- Current schema: `migrations/00001_initial_schema.sql`
- ChunkStorage interface: `pkg/storage/storage.go`
- PostgreSQL implementation: `pkg/storage/postgres.go`
- Historic bug fix: `docs/features/b001-fix-chunks-latest-view/`
- UUID v7 draft spec: https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format
- PostgreSQL UUID documentation: https://www.postgresql.org/docs/current/datatype-uuid.html
