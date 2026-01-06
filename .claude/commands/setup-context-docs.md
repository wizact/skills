# Setup Context-Driven Development Documentation

**Description**: Creates a comprehensive context-driven development documentation structure for any repository, based on proven patterns from code-transformer and go-todo-api.

**Usage**:
```
/setup-context-docs
```

**What it does**:
1. Analyzes the current repository (language, tech stack, architecture)
2. Creates a multi-document constitution pattern with clear separation of concerns
3. Generates language-agnostic feature specification templates
4. Updates README.md with documentation references
5. Migrates existing conventions/rules if found (EXCLUDES .github/CONTRIBUTING.md)

---

## Core Principles

### 1. Progressive Disclosure (CLAUDE.md)
**CLAUDE.md must be CONCISE** - think of it as a navigation hub, not an encyclopedia.
- Quick wins: Commands, key paths, 1-paragraph architecture
- Progressive disclosure: Link to detailed docs, don't duplicate
- Target: 800-1200 words MAX (like go-todo-api)
- Rule: If it needs >3 paragraphs of explanation, move it to constitution/

### 2. No Duplication
- Each piece of information lives in ONE place
- Other documents LINK to it, don't repeat it
- Example: Database schema details in tech.md, product.md just says "PostgreSQL storage"

### 3. Product vs Technical Separation
**product.md** = Business/Product perspective (NO technical details):
- WHAT problem does this solve?
- WHO are the users?
- WHAT features exist?
- WHAT is in/out of scope?
- NO: Database schemas, API designs, algorithms

**tech.md** = Technical perspective (ALL technical details):
- WHY this technology stack?
- HOW is the architecture structured?
- WHAT are the technical patterns?
- Database schemas, performance targets, deployment

### 4. WHAT vs HOW Separation
**requirements.md** = WHAT to build (specifications):
- WHAT features/capabilities
- WHAT acceptance criteria (GIVEN/WHEN/THEN)
- WHAT performance targets
- WHAT is out of scope
- NO: Implementation details, algorithms, components

**design.md** = HOW to build it (implementation):
- HOW will architecture work
- WHICH components needed
- WHAT algorithms/data structures
- HOW to test
- Implementation-specific details

---

## Instructions for Claude

When this skill is invoked, follow these steps:

### Phase 1: Repository Analysis (Read-Only)

**Goal**: Understand the repository to fill in documentation templates appropriately.

**Tasks**:
1. **Detect primary language(s)**:
   - Check file extensions (`.go`, `.py`, `.js`, `.ts`, etc.)
   - Read build files: `go.mod`, `package.json`, `pom.xml`, etc.
   - Identify version if specified

2. **Identify tech stack**:
   - Databases: `docker-compose.yml`, migrations, connection strings
   - Frameworks: Dependencies (Express, Django, Spring, etc.)
   - Build tools: Makefile, package.json scripts
   - Testing: Test files and dependencies

3. **Understand architecture** (high-level only):
   - Directory structure patterns
   - Module organization (monolith, libs, microservices)
   - Layer separation if obvious

4. **Check existing documentation**:
   - `.claude/project_rules.md` (MIGRATE)
   - `CONVENTIONS.md` or similar (MIGRATE)
   - **EXCLUDE**: `.github/CONTRIBUTING.md` (out of scope, leave it alone)
   - README.md structure

5. **Extract metadata**:
   - Project name
   - Description (from README or package files)
   - Current roadmap/features
   - Key dependencies

---

### Phase 2: Create Documentation Structure

#### 2.1: Create Root CLAUDE.md (KEEP IT CONCISE!)

**File**: `CLAUDE.md`

**Target**: 800-1200 words MAX (similar to go-todo-api)

**Content** (use progressive disclosure):

1. **Project Overview** (2-3 sentences):
   - ONE sentence: What is this project?
   - ONE sentence: Core purpose
   - Example: "Code-chunker is a semantic code parsing library. Extracts functions, types, and variables with metadata for LLM processing."

2. **Quick Reference** (links only):
   ```markdown
   ## Quick Reference

   - **Product**: [docs/constitution/product.md](docs/constitution/product.md) - Vision, scope, roadmap
   - **Technical**: [docs/constitution/tech.md](docs/constitution/tech.md) - Architecture, stack, patterns
   - **Conventions**: [docs/conventions.md](docs/conventions.md) - [Language] coding standards
   - **Features**: [docs/features/](docs/features/) - Feature planning templates
   ```

3. **Architecture** (diagram + 1 paragraph):
   - Directory tree (actual structure, concise)
   - ONE paragraph explaining layers/flow
   - Link to tech.md for details: "See [tech.md](docs/constitution/tech.md) for detailed architecture"

4. **Development Commands** (essential only):
   - Build, test, run, lint
   - Link to full list if >10 commands

5. **Key Technologies** (list + one-liner each):
   - Just names and versions
   - Brief role (1 line)
   - Link to tech.md for rationale: "See tech.md for technology decisions"

6. **Module Structure** (overview only):
   - High-level organization
   - Dependency flow if clear
   - Link to tech.md for details

**What NOT to include**:
- ❌ Detailed architecture explanations (→ tech.md)
- ❌ Technology rationale (→ tech.md)
- ❌ Coding standards (→ conventions.md)
- ❌ Product scope (→ product.md)
- ❌ Testing strategies (→ tech.md)
- ❌ Database schemas (→ tech.md)

**Rule**: If you're writing >3 paragraphs on a topic, move it to the appropriate constitution document and link instead.

---

#### 2.2: Create docs/constitution/product.md (NO TECHNICAL DETAILS)

**File**: `docs/constitution/product.md`

**Focus**: Product/Business perspective - What, Who, Why (NOT How)

**Content sections**:

1. **Core Mission**:
   - WHY does this exist?
   - WHAT problem does it solve?
   - WHO benefits?

2. **Key Features** (current):
   - WHAT capabilities exist?
   - User-facing features only
   - NO implementation details

3. **Target Audience**:
   - Primary users
   - Secondary users
   - Use cases

4. **Important Scope Decisions**:
   - WHAT is in scope
   - WHAT is out of scope (PERMANENTLY)
   - WHAT is out of scope (v1.0)
   - Future direction

5. **Success Criteria** (business metrics):
   - User adoption targets
   - Feature completeness
   - Quality from user perspective
   - NO: Technical performance metrics (→ tech.md)

6. **Roadmap Phases**:
   - Feature roadmap
   - User-facing milestones
   - NO: Technical migrations (→ tech.md)

**What to EXCLUDE**:
- ❌ Database schemas
- ❌ API designs
- ❌ Algorithms
- ❌ Technology choices
- ❌ Architecture patterns
- ❌ Performance benchmarks
- ❌ Security implementations

**Example boundaries**:
- ✅ "Stores code chunks with version tracking" (product feature)
- ❌ "PostgreSQL with auto-increment via get_next_version() SQL function" (technical detail → tech.md)

---

#### 2.3: Create docs/constitution/tech.md (ALL TECHNICAL DETAILS)

**File**: `docs/constitution/tech.md`

**Focus**: Technical perspective - How, Why tech choices, Implementation

**Content sections**:

1. **Technology Stack Rationale**:
   - WHY each technology chosen
   - Trade-offs (pros/cons)
   - Alternatives considered

2. **Architecture Patterns**:
   - Detailed architecture explanation
   - Layer separation
   - Design patterns used
   - Component interactions

3. **Database Design** (if applicable):
   - Schema details
   - Indexes, constraints
   - Migration strategy
   - Query patterns

4. **Testing Requirements**:
   - Framework details
   - Coverage targets
   - Test organization
   - CI/CD specifics

5. **Performance Targets** (technical metrics):
   - Latency, throughput
   - Memory, CPU usage
   - Benchmark results
   - Optimization strategies

6. **Security & Operations**:
   - Security patterns
   - Deployment architecture
   - Configuration management
   - Monitoring

7. **Dependency Policy**:
   - Dependency management
   - Version pinning
   - Audit process

**What to INCLUDE** (everything technical):
- ✅ Database schemas with SQL
- ✅ API endpoint designs
- ✅ Algorithm explanations
- ✅ Performance benchmarks
- ✅ Technology trade-offs
- ✅ Build/deployment details

---

#### 2.4: Create docs/conventions.md

**File**: `docs/conventions.md`

**Content**: Language-specific coding patterns and practices
   - Language-specific conventions
   - Naming, formatting, organization
   - Error handling patterns
   - Testing strategies

**Reference Implementation**:

Check if language-specific convention file exists in this repository. Available reference implementations:

| Language | GitHub URL |
|----------|--------------|
| Go | [Go Conventions Template](https://github.com/wizact/dotclaude/blob/main/TEMPLATES/conventions/go/conventions.md) |
| Python | [Python Conventions Template](https://github.com/wizact/dotclaude/blob/main/TEMPLATES/conventions/python/conventions.md) |

**Creation Strategy**:
1. **If language-specific convention exists in TEMPLATES/**:
   - Use as reference for structure and content
   - Adapt to current project specifics
   - Follow the same section organization

2. **If no template exists for detected language**:
   - Create `docs/conventions.md` with placeholder sections
   - Add note at top: "⚠️ This file contains placeholders. Please complete with project-specific conventions."
   - Use standard sections below with `TODO:` markers
   - User will complete later

**Sections**:
1. Code Conventions (filenames, naming, structure)
2. Testing Conventions (frameworks, patterns, organization)
3. Error Handling (language-specific patterns)
4. Package/Module Organization
5. Interface/Contract Design (if applicable)
6. Git Workflow
7. Extending/Adding Features (step-by-step guide)

**Migration**:
- IF `.claude/project_rules.md` exists:
  - Read, migrate content, DELETE original
  - Note migration in commit
- IF `CONVENTIONS.md` exists:
  - Read, consolidate into `docs/conventions.md`
  - Consider keeping original if substantial
- **EXCLUDE**: `.github/CONTRIBUTING.md` (leave it alone, out of scope)

---

#### 2.5: Create docs/features/README.md

**File**: `docs/features/README.md`

**Content**: Language-agnostic feature specification guide

**Reference Implementation**:

A reference README.md is available that explains the feature specification structure:
- **GitHub URL**: [Context-Docs README Template](https://github.com/wizact/dotclaude/blob/main/TEMPLATES/context-docs/README.md)
- **Use as**: Foundation for creating docs/features/README.md
- **Adapt**: Customize for project-specific workflow and conventions

**Key sections**:
1. **Structure**: Three-document pattern
   - **requirements.md** = WHAT to build (specifications, acceptance criteria, targets)
   - **design.md** = HOW to build (architecture, components, implementation)
   - **tasks.md** = Execution tracking (phases, progress, lessons)

2. **Clear WHAT vs HOW separation**:
   - Requirements: Business logic, user needs, specifications
   - Design: Technical solutions, implementation choices

3. **Philosophy**: "Templates serve you, not vice versa"

4. **Workflow**: Requirements → Design → Tasks → Implementation → Archive

5. **GitHub Traceability**: Link to issues/PRs

---

#### 2.6: Create Feature Templates

**Files**:
- `docs/features/TEMPLATES/requirements.md.template`
- `docs/features/TEMPLATES/design.md.template`
- `docs/features/TEMPLATES/tasks.md.template`

**Reference Implementation**:

A complete example feature specification is available to learn from:
- **Feature**: UUID Multi-Repo Support (f002-uuid-multi-repo)
- **GitHub URL**: [Example Feature Spec](https://github.com/wizact/dotclaude/tree/main/TEMPLATES/context-docs/features/f002-uuid-multi-repo)
- **Contains**: Complete requirements.md, design.md, tasks.md
- **Use as**: Reference for structure, section organization, and level of detail

**When creating templates**:
1. Review the f002-uuid-multi-repo example to understand:
   - How to structure requirements with EARS notation
   - How to separate concerns between requirements and design
   - How to break down implementation into trackable tasks
   - Appropriate level of detail for each document
2. Adapt the structure to be language-agnostic templates
3. Include placeholder sections with clear guidance

**requirements.md.template**:
- Focus: WHAT (specifications, not implementation)
- Sections:
  - GitHub Issue reference
  - Overview (WHAT problem, WHY needed)
  - Functional Requirements (GIVEN/WHEN/THEN)
  - Performance Targets (WHAT metrics)
  - Success Metrics (HOW to measure)
  - Out of Scope (WHAT not to do)
  - Open Questions
- NO: Implementation details, algorithms, components

**design.md.template**:
- Focus: HOW (implementation, not specifications)
- Sections:
  - GitHub Issue reference
  - Architecture Overview (HOW it works)
  - Components (WHICH parts needed)
  - Data Structures (HOW to model)
  - Algorithms (HOW to process)
  - Database Changes (HOW schema evolves)
  - API Changes (HOW interfaces change)
  - Testing Approach (HOW to test)
- YES: All implementation details

**tasks.md.template**:
- Focus: Execution (phases, tracking, retrospective)
- Sections:
  - GitHub Issue reference
  - Overview (estimates, assignment)
  - Phases (breakdown into 2-3 hour chunks)
  - Progress Tracking (status updates)
  - Lessons Learned (retrospective)

**Language adaptation**:
- Use detected language for code examples
- Adjust framework terminology
- Keep structure language-agnostic

---

### Phase 3: Update Existing Documentation

#### 3.1: Update README.md

**Add Documentation Section** (after features/installation):
```markdown
## Documentation

### For Developers

- **[CLAUDE.md](CLAUDE.md)** - Quick reference and navigation hub
- **[docs/constitution/product.md](docs/constitution/product.md)** - Product vision, scope, and roadmap
- **[docs/constitution/tech.md](docs/constitution/tech.md)** - Technical architecture and decisions
- **[docs/conventions.md](docs/conventions.md)** - [Language] coding standards and patterns
- **[docs/features/](docs/features/)** - Feature specification templates

**Start here**: New contributors should read CLAUDE.md first for quick orientation.
```

**Update references**:
- Fix links to moved documentation
- Update "Contributing" to reference `docs/conventions.md`
- Update "Extending" to reference appropriate docs
- Clarify roadmap scope (link to product.md if needed)

**Preserve**:
- Existing structure
- Feature lists
- Installation instructions
- All user-facing content

---

#### 3.2: Handle Existing Conventions

**Migrate these**:
- `.claude/project_rules.md` → `docs/conventions.md` (DELETE original)
- `CONVENTIONS.md` → `docs/conventions.md` (consolidate, consider keeping original)

**Leave alone** (OUT OF SCOPE):
- ❌ `.github/CONTRIBUTING.md` - Community contributions, separate concern
- ❌ `.github/CODE_OF_CONDUCT.md` - Community standards
- ❌ `.github/PULL_REQUEST_TEMPLATE.md` - GitHub-specific

---

### Phase 4: Ask User for Clarifications

**Before finalizing**, use `AskUserQuestion` for:

1. **Scope boundaries** (if unclear):
   - Question: "What is explicitly OUT of scope for [project name]?"
   - Provide discovered features to help
   - 3-4 options based on project type

2. **Migration approach**:
   - Question: "How should I handle existing convention files?"
   - Options:
     - "Migrate and delete (Recommended)"
     - "Migrate but keep originals"
     - "Just add new docs, don't touch existing"

3. **Example feature**:
   - Question: "Create example feature spec from roadmap?"
   - Options:
     - "Yes, use first roadmap item"
     - "No, just templates"

---

### Phase 5: Quality Checks

**Before creating files, verify**:

**CLAUDE.md** (conciseness check):
- [ ] <1200 words total
- [ ] No >3 paragraph sections (move to constitution/)
- [ ] Links to detailed docs, doesn't duplicate
- [ ] Acts as navigation hub, not encyclopedia

**product.md** (product-only check):
- [ ] No database schemas
- [ ] No API designs
- [ ] No algorithms
- [ ] No technology rationale
- [ ] Focus on WHAT/WHO/WHY, not HOW

**tech.md** (technical-only check):
- [ ] Has ALL technical details
- [ ] Database schemas present (if applicable)
- [ ] Architecture diagrams/explanations
- [ ] Technology trade-offs explained

**No duplication check**:
- [ ] Database schema in ONE place (tech.md)
- [ ] Technology list in ONE place (CLAUDE.md brief, tech.md details)
- [ ] Architecture in ONE place (CLAUDE.md overview, tech.md deep dive)

**WHAT vs HOW separation**:
- [ ] requirements.md has NO implementation details
- [ ] design.md has NO business requirements
- [ ] Clear handoff between specification and implementation

---

### Phase 6: Create Files and Commit

**File creation order**:
1. `CLAUDE.md`
2. `docs/constitution/product.md`
3. `docs/constitution/tech.md`
4. `docs/conventions.md`
5. `docs/features/README.md`
6. `docs/features/TEMPLATES/*.template`
7. Update `README.md`
8. Delete migrated files

**Commit**:
```bash
git add CLAUDE.md docs/ README.md
git rm .claude/project_rules.md  # if migrating
git commit -S -m "docs: establish context-driven development documentation

- Add CLAUDE.md as concise navigation hub with progressive disclosure
- Create constitution pattern (product.md, tech.md) with clear separation:
  * product.md: Business perspective (WHAT/WHO/WHY, no tech details)
  * tech.md: Technical perspective (HOW/architecture/all tech details)
- Add conventions.md with [Language]-specific patterns
- Create feature templates with WHAT vs HOW separation:
  * requirements.md: Specifications and acceptance criteria
  * design.md: Implementation and technical decisions
- Update README.md with documentation navigation
- Migrate .claude/project_rules.md to docs/conventions.md

Based on proven patterns from code-transformer and go-todo-api.
Establishes foundation for AI agents and contributor onboarding.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Phase 7: Summary Report

**Provide**:

1. **Files Created**: List with sizes
2. **Files Modified**: README.md changes
3. **Files Deleted**: Migrated files
4. **Key Insights**:
   - Detected language and version
   - Tech stack summary
   - Architecture pattern observed
5. **Document Separation Verification**:
   - CLAUDE.md word count (should be <1200)
   - product.md has no technical details ✓
   - tech.md has all technical details ✓
   - No duplication between docs ✓
6. **Next Steps**:
   - Review scope boundaries in product.md
   - Verify technology rationale in tech.md
   - Customize conventions.md for team patterns

---

## Edge Cases

### Multi-Language Repos
- Ask which language is primary for conventions
- Consider language-specific convention files

### Monorepos
- Ask: Root-level or per-package docs?
- Adjust structure accordingly

### Extensive Existing Docs
- Don't overwrite
- Ask how to integrate
- Consider creating alongside

### No README
- Create basic README first
- Include documentation section

---

## Language Adaptations

**Adapt conventions.md for**:
- Python: PEP 8, snake_case, type hints, pytest
- JavaScript/TypeScript: camelCase, ESLint, Jest
- Java: PascalCase, JUnit, Maven/Gradle
- Rust: snake_case, Cargo, built-in testing
- Ruby: snake_case, RSpec, Bundler

**Adapt examples in templates for detected language**

---

## Success Criteria

- [ ] CLAUDE.md is <1200 words and acts as navigation hub
- [ ] product.md contains ZERO technical implementation details
- [ ] tech.md contains ALL technical details
- [ ] No information is duplicated across documents
- [ ] requirements.md focuses on WHAT (specifications)
- [ ] design.md focuses on HOW (implementation)
- [ ] All cross-references are valid links
- [ ] README.md documentation section added
- [ ] .github/CONTRIBUTING.md left untouched (out of scope)
- [ ] Commit message follows conventional commits