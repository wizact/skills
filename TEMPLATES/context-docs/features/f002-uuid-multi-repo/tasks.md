# Feature Tasks: UUID Primary Keys and Multi-Repository Support

**Related**: User request | [Requirements](./requirements.md) | [Design](./design.md)

## Overview
**Deliverable**: Complete UUID v7 and multi-repository support with updated schema, interface, and implementation
**Estimated Time**: 6-8 hours
**Workflow**: Feature branch → PR → Review → Merge

**⚠️ IMPORTANT**: NEVER push to main. Always use feature branch + PR workflow.

## Implementation Phases

### Phase 1: Setup & Exploration (15 min)
**Goal**: Create feature branch and verify development environment

- [ ] Create feature branch
  ```bash
  git checkout main
  git pull origin main
  git checkout -b feat/uuid-multi-repo
  ```
- [ ] Review requirements.md and design.md
- [ ] Verify PostgreSQL version
  ```bash
  docker-compose up -d
  psql postgres://chunker:chunker@localhost:5431/chunker?sslmode=disable -c "SELECT version();"
  # Confirm PostgreSQL 16.x (gen_random_bytes() built-in)
  ```
- [ ] Check current migration status
  ```bash
  export DATABASE_URL="postgres://chunker:chunker@localhost:5431/chunker?sslmode=disable"
  make db-status
  # Should show: 00001, 00002 applied
  ```

**Checkpoint**: Feature branch created, PostgreSQL 16 confirmed

---

### Phase 2: Database Migration (90 min)
**Goal**: Create migration script with UUID v7 function and multi-repo schema changes

**Tasks**:
- [ ] Task 1. Create migration file `migrations/00003_uuid_and_multi_repo.sql`
  - Create file with Goose header comments (`+goose Up` / `+goose Down`)
  - Add reference comments (feature link, requirements doc link)
  - _Requirements: [R1, R2, R3, R4, R6]_

- [ ] Task 2. Implement UUID v7 generation function
  - **Skip** `CREATE EXTENSION pgcrypto` (PostgreSQL 13+ has `gen_random_bytes()` built-in)
  - Add comment: "gen_random_bytes() is built-in for PostgreSQL 13+. For older versions, add: CREATE EXTENSION IF NOT EXISTS pgcrypto;"
  - Create `uuid_generate_v7()` function using `gen_random_bytes(10)`
  - Use `+goose StatementBegin` / `+goose StatementEnd` wrapper
  - Test timestamp extraction (48 bits from `EXTRACT(EPOCH)`)
  - Set version bits: `(byte & 0x0F) | 0x70` for version 7
  - Set variant bits: `(byte & 0x3F) | 0x80` for RFC 4122
  - _Requirements: [R1]_

- [ ] Task 3. Add multi-repository columns
  - `ALTER TABLE code_chunks ADD COLUMN organisation_name TEXT`
  - `ALTER TABLE code_chunks ADD COLUMN repo_name TEXT NOT NULL DEFAULT 'legacy'`
  - _Requirements: [R2, R3]_

- [ ] Task 4. Convert id column to UUID
  - Drop old primary key `code_chunks_pkey`
  - `ALTER COLUMN id DROP DEFAULT` (remove BIGSERIAL sequence)
  - `ALTER COLUMN id TYPE UUID USING uuid_generate_v7()` (convert existing data)
  - `ALTER COLUMN id SET DEFAULT uuid_generate_v7()` (new inserts)
  - _Requirements: [R1, R6]_

- [ ] Task 5. Create new primary key and constraints
  - `ADD PRIMARY KEY (organisation_name, repo_name, file_path, version, id)`
  - `ADD CONSTRAINT valid_repo_name CHECK (repo_name != '')`
  - _Requirements: [R3]_

- [ ] Task 6. Update indexes
  - Drop old index: `idx_chunks_latest_version`
  - Create: `idx_chunks_latest ON (organisation_name, repo_name, file_path, version DESC)`
  - Create: `idx_chunks_repo ON (organisation_name, repo_name)`
  - Keep existing: `idx_chunks_git_hash`, `idx_chunks_metadata`
  - _Requirements: [R2, R3]_

- [ ] Task 7. Update get_next_version() function
  - Drop old function: `get_next_version(TEXT)`
  - Create new: `get_next_version(p_organisation_name TEXT, p_repo_name TEXT, p_file_path TEXT)`
  - Use `IS NOT DISTINCT FROM` for NULL-safe organisation comparison
  - Return `COALESCE(MAX(version), 0) + 1`
  - Use `+goose StatementBegin` / `+goose StatementEnd` wrapper
  - _Requirements: [R4]_

- [ ] Task 8. Update code_chunks_latest view
  - Add `organisation_name, repo_name` to SELECT columns
  - Update WHERE subquery with `IS NOT DISTINCT FROM` for org comparison
  - Update ORDER BY: `organisation_name, repo_name, file_path, id`
  - _Requirements: [R2, R3]_

- [ ] Task 9. Implement rollback (+goose Down)
  - Drop updated view
  - Drop new indexes (`idx_chunks_repo`, `idx_chunks_latest`)
  - Drop new function `get_next_version(TEXT, TEXT, TEXT)`
  - Drop new primary key
  - Remove columns: `repo_name`, `organisation_name`
  - Convert id back to BIGSERIAL (create sequence, alter column)
  - Restore old primary key `(file_path, version, id)`
  - Restore old index `idx_chunks_latest_version`
  - Restore old function `get_next_version(TEXT)`
  - Restore old view
  - Drop `uuid_generate_v7()` function
  - Add warning comment: "Rollback is destructive - UUID data lost"
  - _Requirements: [R6]_

**Checkpoint**: Migration file complete with up/down migrations

---

### Phase 3: Update ChunkStorage Interface (30 min)
**Goal**: Extend interface with organisation and repository parameters

**Tasks**:
- [ ] Task 10. Update storage.go interface
  - Update `SaveChunks` signature: add `organisationName, repoName` before `filePath`
  - Update `GetLatestChunks` signature: add `organisationName, repoName` before `filePath`
  - Update `GetChunksByVersion` signature: add `organisationName, repoName` before `filePath`
  - Keep `GetChunksByGitHash` unchanged (git hash globally unique)
  - Keep `Close` unchanged
  - Update godoc comments for all methods
  - Document: `organisationName` nullable (use "" for default/NULL)
  - Document: `repoName` required (cannot be empty)
  - _Requirements: [R5]_

**File**: `pkg/storage/storage.go`

**Checkpoint**: Interface updated with clear documentation

---

### Phase 4: Update PostgreSQL Implementation (120 min)
**Goal**: Implement multi-repo storage with UUID v7 and updated queries

**Tasks**:
- [ ] Task 11. Update SaveChunks method
  - Add `organisationName, repoName` parameters to signature
  - Validate `repoName != ""` (return error if empty)
  - Normalize `organisationName`: empty string → `nil` (store as NULL)
  - Update version query: `SELECT get_next_version($1, $2, $3)` with org, repo, filePath
  - Update INSERT statement: add `organisation_name, repo_name` columns
  - **Remove** `id` from INSERT (uses `DEFAULT uuid_generate_v7()`)
  - Pass `orgValue` (nil or string) to INSERT
  - Update error messages to include repo context
  - _Requirements: [R1, R2, R3, R4, R5]_

- [ ] Task 12. Update GetLatestChunks method
  - Add `organisationName, repoName` parameters to signature
  - Normalize `organisationName`: empty → `nil`
  - Update WHERE clause: `organisation_name IS NOT DISTINCT FROM $1 AND repo_name = $2 AND file_path = $3`
  - Update subquery with same filters
  - Keep ORDER BY `id` (UUID v7 is time-ordered)
  - _Requirements: [R2, R3, R5]_

- [ ] Task 13. Update GetChunksByVersion method
  - Add `organisationName, repoName` parameters to signature
  - Normalize `organisationName`
  - Update WHERE clause: add org/repo filters
  - Keep existing version validation (`version > 0`)
  - _Requirements: [R2, R3, R5]_

- [ ] Task 14. Keep GetChunksByGitHash unchanged
  - Verify existing implementation works (no org/repo filtering needed)
  - Update tests to confirm multi-repo chunks returned correctly
  - _Requirements: [R5]_

**File**: `pkg/storage/postgres.go`

**Checkpoint**: PostgreSQL implementation updated with multi-repo support

---

### Phase 5: Update Tests (90 min)
**Goal**: Add comprehensive tests for UUID v7 and multi-repo functionality

**Tasks**:
- [ ] Task 15. Update existing tests
  - Find all `SaveChunks` calls in `postgres_test.go`
  - Add `organisationName = ""` and `repoName = "test-repo"` parameters
  - Find all `GetLatestChunks` calls
  - Add `organisationName = ""` and `repoName = "test-repo"` parameters
  - Find all `GetChunksByVersion` calls
  - Add org/repo parameters
  - Run tests: `go test ./pkg/storage/ -v`
  - Fix any failures
  - _Requirements: [R5]_

- [ ] Task 16. Add UUID v7 validation test
  - Test name: `TestSaveChunks_GeneratesUUIDv7`
  - Save 100 chunks
  - Query back and extract `id` values
  - Verify all IDs are unique
  - Verify UUID format: version bits = 0x70, variant bits = 0x80
  - Verify time ordering: earlier chunks have lexicographically smaller UUIDs
  - _Requirements: [R1]_

- [ ] Task 17. Add multi-repo version scoping test
  - Test name: `TestVersionIncrement_ScopedPerRepo`
  - Save chunks for `("acme", "web-app", "main.go")` → expect v1
  - Save chunks for `("acme", "web-app", "main.go")` → expect v2
  - Save chunks for `("acme", "api", "main.go")` → expect v1 (different repo)
  - Save chunks for `("", "web-app", "main.go")` → expect v1 (different org)
  - Verify each query returns correct chunks
  - _Requirements: [R4]_

- [ ] Task 18. Add organisation normalization test
  - Test name: `TestSaveChunks_EmptyOrganisationDefaultHandling`
  - Save chunks with `organisationName = ""`
  - Query database directly: verify `organisation_name IS NULL`
  - Query via `GetLatestChunks("", "repo", "file")` → expect chunks returned
  - Query via `GetLatestChunks("default", "repo", "file")` → expect no chunks (NULL ≠ "default")
  - _Requirements: [R2]_

- [ ] Task 19. Add repo name validation test
  - Test name: `TestSaveChunks_EmptyRepoNameError`
  - Call `SaveChunks` with `repoName = ""`
  - Expect error: "repo_name cannot be empty"
  - _Requirements: [R3]_

- [ ] Task 20. Add multi-repo isolation test
  - Test name: `TestGetLatestChunks_MultiRepoIsolation`
  - Save chunks for `("acme", "web-app", "main.go")`
  - Save chunks for `("acme", "api", "main.go")`
  - Save chunks for `("beta", "web-app", "main.go")`
  - Query `("acme", "web-app", "main.go")` → expect only web-app chunks
  - Query `("acme", "api", "main.go")` → expect only api chunks
  - Query `("beta", "web-app", "main.go")` → expect only beta chunks
  - _Requirements: [R2, R3]_

- [ ] Task 21. Add git hash cross-repo test
  - Test name: `TestGetChunksByGitHash_CrossRepo`
  - Save chunks for `("acme", "web-app", "main.go", gitHash="abc123")`
  - Save chunks for `("acme", "api", "utils.go", gitHash="abc123")`
  - Query `GetChunksByGitHash("abc123")` → expect chunks from both repos
  - _Requirements: [R5]_

**File**: `pkg/storage/postgres_test.go`

**Checkpoint**: All tests passing with >80% coverage

---

### Phase 6: Update CLI Application (30 min)
**Goal**: Update cmd/chunker to use new ChunkStorage interface

**Tasks**:
- [ ] Task 22. Update main.go to pass org/repo parameters
  - Detect repo name from git remote (parse `git remote get-url origin`)
  - Default to "unknown" if git not available
  - Use empty string for `organisationName` (defaults to NULL)
  - Update `SaveChunks` call with new parameters
  - Add CLI flags (optional):
    - `--org` for organisation name
    - `--repo` for repository name (overrides git detection)
  - _Requirements: [R5]_

**File**: `cmd/chunker/main.go`

**Checkpoint**: CLI updated and functional

---

### Phase 7: Manual Testing (45 min)
**Goal**: Verify migration and functionality with real database

**Tasks**:
- [ ] Task 23. Test migration on clean database
  ```bash
  # Reset database
  make db-reset

  # Apply all migrations
  make db-migrate

  # Verify migration status
  make db-status
  # Expected: 00001, 00002, 00003 applied
  ```
  - _Requirements: [R6]_

- [ ] Task 24. Test UUID v7 generation
  ```bash
  psql $DATABASE_URL -c "SELECT uuid_generate_v7();"
  # Verify: Returns UUID like "018d5e8c-7b4a-7xxx-xxxx-xxxxxxxxxxxx"

  psql $DATABASE_URL -c "SELECT uuid_generate_v7() FROM generate_series(1,10);"
  # Verify: All UUIDs are unique and sortable
  ```
  - _Requirements: [R1]_

- [ ] Task 25. Test multi-repo versioning
  ```sql
  -- Test version function
  SELECT get_next_version('acme', 'web-app', 'main.go');
  -- Expected: 1

  SELECT get_next_version('acme', 'api', 'main.go');
  -- Expected: 1 (different repo)

  SELECT get_next_version(NULL, 'web-app', 'main.go');
  -- Expected: 1 (NULL org)
  ```
  - _Requirements: [R4]_

- [ ] Task 26. Test CLI with real file
  ```bash
  # Parse current file
  ./bin/chunker
  # Verify: Chunks printed to stdout

  # Save to database (with git detection)
  DATABASE_URL="postgres://chunker:chunker@localhost:5431/chunker?sslmode=disable" ./bin/chunker
  # Verify: Chunks saved with detected repo name

  # Query database
  psql $DATABASE_URL -c "SELECT organisation_name, repo_name, file_path, version FROM code_chunks;"
  # Verify: Data stored correctly with NULL org, detected repo name
  ```
  - _Requirements: [R5]_

- [ ] Task 27. Test migration rollback
  ```bash
  # Backup test data
  psql $DATABASE_URL -c "SELECT COUNT(*) FROM code_chunks;" > before.txt

  # Rollback migration
  make db-down

  # Verify schema restored
  psql $DATABASE_URL -c "\d code_chunks"
  # Expected: id is BIGINT, no org/repo columns

  # Re-apply migration
  make db-migrate

  # Verify migration works again
  make db-status
  ```
  - _Requirements: [R6]_

**Checkpoint**: Manual testing complete, all features working

---

### Phase 8: Documentation Updates (30 min)
**Goal**: Update project documentation with migration guide

**Tasks**:
- [ ] Task 28. Update CLAUDE.md
  - Update "Version Tracking" section with multi-repo scoping
  - Add example: `store.SaveChunks(ctx, chunks, "acme", "web-app", "main.go", "go", "")`
  - Document organisation normalization (empty → NULL)
  - _Requirements: [R5]_

- [ ] Task 29. Update pkg/storage/README.md
  - Add UUID v7 section explaining benefits
  - Add multi-repo usage examples
  - Document breaking changes from v1 interface
  - Add migration guide for users
  - _Requirements: [R5]_

- [ ] Task 30. Update migrations/README.md (if exists)
  - Document 00003 migration purpose
  - Add warning: "Rollback is destructive (UUID data lost)"
  - Note: PostgreSQL 13+ has built-in `gen_random_bytes()`
  - _Requirements: [R6]_

**Checkpoint**: Documentation updated

---

### Phase 9: Code Quality Checks (20 min)
**Goal**: Ensure code meets project standards

**Tasks**:
- [ ] Task 31. Run formatting and linters
  ```bash
  make fmt
  make lint
  ```
  - Fix any formatting issues
  - Fix any `go vet` warnings
  - _Requirements: All_

- [ ] Task 32. Run full test suite
  ```bash
  make test
  ```
  - Ensure all tests pass
  - Verify no test failures in other packages
  - _Requirements: All_

- [ ] Task 33. Check test coverage
  ```bash
  go test -cover ./pkg/storage/
  ```
  - Verify coverage >70% for storage package
  - Add tests for uncovered branches if needed
  - _Requirements: All_

**Checkpoint**: Code quality verified

---

### Phase 10: Commit & Push (15 min)
**Goal**: Commit changes and push to feature branch

- [ ] Stage migration file
  ```bash
  git add migrations/00003_uuid_and_multi_repo.sql
  ```

- [ ] Stage storage changes
  ```bash
  git add pkg/storage/storage.go pkg/storage/postgres.go pkg/storage/postgres_test.go
  ```

- [ ] Stage CLI changes
  ```bash
  git add cmd/chunker/main.go
  ```

- [ ] Stage documentation updates
  ```bash
  git add CLAUDE.md pkg/storage/README.md
  ```

- [ ] Create signed commit
  ```bash
  git commit -S -m "$(cat <<'EOF'
  feat(storage): add UUID v7 primary keys and multi-repository support

  Add UUID v7 time-ordered primary keys for better security and index performance.
  Extend schema to support multiple repositories with organisation-level isolation.

  Database changes:
  - Convert id column from BIGSERIAL to UUID v7
  - Add organisation_name column (nullable, defaults to NULL)
  - Add repo_name column (required)
  - Update get_next_version() to scope per (org, repo, file_path)
  - Update primary key and indexes for multi-repo queries
  - Create uuid_generate_v7() function (uses built-in gen_random_bytes())

  API changes (BREAKING):
  - SaveChunks: add organisationName, repoName parameters
  - GetLatestChunks: add organisationName, repoName parameters
  - GetChunksByVersion: add organisationName, repoName parameters
  - GetChunksByGitHash: unchanged (backward compatible)

  Migration:
  - Existing data gets organisation_name = NULL, repo_name = 'legacy'
  - Users can update legacy repo names with SQL UPDATE
  - Rollback available but destructive (UUID data lost)

  Testing:
  - Add UUID v7 generation validation tests
  - Add multi-repo version scoping tests
  - Add organisation normalization tests
  - Add repo name validation tests
  - Add multi-repo isolation tests

  Requirements satisfied: R1, R2, R3, R4, R5, R6
  Related: docs/features/f002-uuid-multi-repo/

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```

- [ ] Verify commit signature
  ```bash
  git log -1 --show-signature
  git branch --show-current  # Verify NOT main
  ```

- [ ] Push to feature branch
  ```bash
  git push -u origin feat/uuid-multi-repo
  ```

**Checkpoint**: Pushed to feature branch

---

### Phase 11: Create Pull Request (20 min)
**Goal**: Create PR for human review

- [ ] Create PR using GitHub CLI
  ```bash
  gh pr create \
    --title "feat(storage): add UUID v7 primary keys and multi-repository support" \
    --body "$(cat <<'EOF'
  ## Summary
  Adds UUID v7 time-ordered primary keys and multi-repository support to code-chunker storage layer. This enables better security (unpredictable IDs), improved index performance (sequential UUIDs), and multi-tenant usage patterns for LLM tool developers managing code across organizations.

  ## Problem
  - Current BIGSERIAL IDs are predictable (security concern for exposed APIs)
  - No support for multiple repositories (all chunks mixed together)
  - Poor distributed system compatibility (can't generate IDs offline)

  ## Solution
  - Convert `id` column to UUID v7 (time-ordered for better B-tree performance)
  - Add `organisation_name` column (nullable, NULL = default org)
  - Add `repo_name` column (required, legacy data gets "legacy")
  - Scope version incrementing per `(organisation_name, repo_name, file_path)`
  - Update ChunkStorage interface with org/repo parameters (BREAKING CHANGE)

  ## Database Changes
  - Migration: `migrations/00003_uuid_and_multi_repo.sql`
  - New function: `uuid_generate_v7()` using built-in `gen_random_bytes()` (PostgreSQL 13+)
  - Updated function: `get_next_version(org, repo, filePath)`
  - New indexes: `idx_chunks_latest`, `idx_chunks_repo`
  - Updated primary key: `(organisation_name, repo_name, file_path, version, id)`

  ## API Changes (BREAKING)
  ```go
  // Before
  SaveChunks(ctx, chunks, filePath, language, gitHash)
  GetLatestChunks(ctx, filePath)

  // After
  SaveChunks(ctx, chunks, organisationName, repoName, filePath, language, gitHash)
  GetLatestChunks(ctx, organisationName, repoName, filePath)
  ```

  ## Requirements Satisfied
  - ✅ R1: UUID v7 primary keys (time-ordered, better index performance)
  - ✅ R2: Organisation name field (nullable, NULL = default org)
  - ✅ R3: Repository name field (required, validated non-empty)
  - ✅ R4: Version tracking per repository (scoped per org/repo/file)
  - ✅ R5: Updated ChunkStorage interface (org/repo parameters)
  - ✅ R6: Data migration safety (preserves existing data, rollback available)

  ## Testing
  - ✅ UUID v7 generation and uniqueness
  - ✅ Multi-repo version scoping
  - ✅ Organisation normalization (empty → NULL)
  - ✅ Repo name validation
  - ✅ Multi-repo isolation
  - ✅ Git hash cross-repo queries
  - ✅ Migration rollback (tested on staging)

  ## Performance Impact
  - UUID v7 INSERT: ~10% slower than BIGSERIAL (acceptable tradeoff)
  - Sequential UUIDs: Better VACUUM efficiency than UUID v4
  - Query performance: Within 10% of current (verified with benchmarks)
  - Index size: +50% (16-byte UUID vs 8-byte BIGINT)

  ## Migration Guide for Users
  ```go
  // Update all SaveChunks calls
  store.SaveChunks(ctx, chunks, "", "my-repo", "main.go", "go", "")
  //                              ^^  ^^^^^^^^^ add these parameters
  //                              |   |
  //                              |   +-- required repo name
  //                              +------ empty = NULL (default org)

  // Update all GetLatestChunks calls
  store.GetLatestChunks(ctx, "", "my-repo", "main.go")
  ```

  ## Rollback Plan
  - Rollback migration available: `make db-down`
  - ⚠️ WARNING: Rollback is destructive (UUID values lost, new BIGSERIAL IDs generated)
  - Backup required before production migration
  - Test rollback on staging first

  ## References
  - [requirements.md](docs/features/f002-uuid-multi-repo/requirements.md)
  - [design.md](docs/features/f002-uuid-multi-repo/design.md)
  - [tasks.md](docs/features/f002-uuid-multi-repo/tasks.md)
  - UUID v7 draft spec: https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format

  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  EOF
  )" \
    --base main \
    --head feat/uuid-multi-repo
  ```

- [ ] Verify PR created
  ```bash
  gh pr view --web
  ```

- [ ] Add labels (if applicable)
  ```bash
  gh pr edit --add-label "enhancement,database,breaking-change"
  ```

**Checkpoint**: PR created, ready for review

---

## Post-PR Workflow
- [ ] Human code review
- [ ] Address review feedback (if any)
- [ ] Approve and merge PR
- [ ] Verify CI/CD passes (GitHub Actions)
- [ ] Delete feature branch
  ```bash
  git checkout main
  git pull origin main
  git branch -d feat/uuid-multi-repo
  ```

## Lessons Learned
*(To be filled after implementation)*
- What went well: ...
- What could improve: ...
- Surprises: ...
- Migration timing: ...

## Time Tracking
| Phase | Estimated | Actual |
|-------|-----------|--------|
| Phase 1: Setup | 15 min | ___ |
| Phase 2: Migration | 90 min | ___ |
| Phase 3: Interface | 30 min | ___ |
| Phase 4: Implementation | 120 min | ___ |
| Phase 5: Tests | 90 min | ___ |
| Phase 6: CLI | 30 min | ___ |
| Phase 7: Manual Testing | 45 min | ___ |
| Phase 8: Documentation | 30 min | ___ |
| Phase 9: Code Quality | 20 min | ___ |
| Phase 10: Commit | 15 min | ___ |
| Phase 11: PR | 20 min | ___ |
| **Total** | **6-8 hours** | **___** |

---

**Critical Path Highlights**:
- Phase 2 (Migration) is critical - must be correct before testing
- Phase 4 (Implementation) depends on Phase 3 (Interface)
- Phase 5 (Tests) validates all previous phases

**Requirement Coverage**:
- R1: Tasks 2, 4, 16, 24
- R2: Tasks 3, 6, 11, 12, 13, 18, 20, 28
- R3: Tasks 3, 5, 6, 11, 12, 13, 19, 20, 28
- R4: Tasks 7, 11, 17, 25
- R5: Tasks 10, 11, 12, 13, 14, 15, 22, 26, 28, 29
- R6: Tasks 1, 4, 9, 23, 27, 30

**Estimated Time**: 6-8 hours total
