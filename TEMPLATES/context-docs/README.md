# Feature Specifications

This directory contains detailed specifications for new features using a three-document pattern adapted from proven development methodologies.

## Structure

Each feature gets a directory named `f###-short-description/` with three files:

- **requirements.md**: WHAT to build (acceptance criteria, performance targets, out of scope)
- **design.md**: HOW to build it (architecture, components, algorithms, testing approach)
- **tasks.md**: Implementation breakdown (phases, dependencies, lessons learned)

## Naming Convention

Features are numbered sequentially with leading zeros:

- `f001-python-support/` - Python language parsing support
- `f002-embedding-storage/` - Store embeddings from external services (pgvector)
- `f003-batch-cli/` - Batch processing CLI for multi-file parsing
- `f004-git-integration/` - Automatic parsing on git commits

**Numbering rules**:
- Start at `f001` for the first feature
- Increment sequentially (f002, f003, ...)
- Don't reuse numbers from abandoned features
- Three digits (f001, not f1)

## When to Use

**Create feature specs for**:
- New language support (Python, JavaScript, TypeScript, etc.)
- Major architectural changes (new storage backends, API redesigns)
- New storage backends (in-memory, file-based, cloud storage)
- API surface changes (new interfaces, breaking changes)
- Performance-critical features (incremental parsing, parallel processing)
- Integration features (git hooks, CI/CD plugins)

**Skip feature specs for**:
- Bug fixes (use GitHub Issues instead)
- Documentation updates (direct PR)
- Refactoring without behavior change (direct PR)
- Dependency updates (direct PR)
- Minor tweaks or adjustments

## Templates

See `TEMPLATES/` directory for starter templates. Copy and customize:

```bash
# Create new feature spec
cp -r docs/features/TEMPLATES docs/features/f001-python-support

# Edit files
cd docs/features/f001-python-support
vim requirements.md
vim design.md
vim tasks.md
```

## Philosophy

**"Templates serve you, not vice versa"** - Adapt based on feature complexity.

- **Simple features**: May only need `design.md` (skip requirements if obvious, skip tasks if < 4 hours)
- **Medium features**: Use `requirements.md` + `design.md` (skip tasks if straightforward)
- **Complex features**: Use all three documents for full planning and tracking

**Don't over-document**: If a requirement is obvious from the feature name, skip the formal spec.

**Example**:
- "Add Python support" → Full spec (complex, multiple ways to implement, needs design decisions)
- "Fix typo in README" → No spec (obvious, trivial)
- "Add logging to SaveChunks" → Design.md only (clear requirement, needs design for log levels/format)

## Workflow

### 1. Requirements Phase

**Goal**: Define WHAT to build and WHY.

**Process**:
1. Create `f###-feature-name/requirements.md` from template
2. **Reference the source**: If requirements came from a GitHub Issue or PR discussion, add the link at the top of requirements.md
   - Format: `**Related**: [GitHub Issue #123](https://github.com/wizact/code-chunker/issues/123)`
   - This creates traceability from requirement → original discussion
3. Collaborate with stakeholders to define acceptance criteria
4. Use GIVEN/WHEN/THEN format for functional requirements
5. Set measurable performance targets
6. Explicitly list what's out of scope (prevents scope creep)
7. Document open questions for design phase

**Example acceptance criteria**:
```markdown
# Feature Requirements: Python Language Support

**Related**: [GitHub Issue #42](https://github.com/wizact/code-chunker/issues/42)

## Overview
User @contributor requested Python support in Issue #42. This feature adds Python language support to code-chunker...

**Python Function Extraction (FR1)**:
- GIVEN a Python file with function definitions
- WHEN ChunkCode() is called with python.GetLanguage()
- THEN all function definitions are extracted with accurate line numbers
```

**Why reference issues/PRs?**
- **Traceability**: Link requirements back to original user requests or bug reports
- **Context**: Preserves discussion, edge cases, and decisions from the original thread
- **Accountability**: Clear attribution of who requested the feature and why
- **History**: Future developers can see the complete story from request → requirement → implementation

**What if there's no GitHub issue?**

If the feature is internally planned (roadmap item, technical debt, etc.):
1. **Option A**: Create a GitHub Issue first, then reference it
   - Benefit: Centralizes all feature tracking in GitHub
   - Best for: User-facing features, major changes
2. **Option B**: Omit the "Related" line and document the source in Overview
   - Example: `**Source**: Internal roadmap decision from 2025-Q1 planning`
   - Best for: Internal refactoring, technical improvements

### 2. Design Phase

**Goal**: Define HOW to build it.

**Process**:
1. Explore codebase to understand existing patterns
2. Draft architecture and component breakdown in `design.md`
3. Ask clarifying questions (use issues or discussions)
4. Consider trade-offs between approaches
5. Design database schema changes (if needed)
6. Plan testing approach (unit tests, integration tests, fixtures)

**Key questions to answer**:
- What are the main components?
- What data structures are needed?
- What are the key algorithms?
- What database changes are required?
- What are the error handling strategies?
- How will this be tested?

### 3. Tasks Phase

**Goal**: Break down implementation into manageable chunks.

**Process**:
1. Create `tasks.md` from template
2. Break work into 2-3 hour phases
3. Identify dependencies between phases
4. Track progress as you implement
5. **During implementation**: Update "Lessons Learned" section
6. Document surprises, challenges, what worked well

**Example phases**:
```markdown
## Phase 1: Core Parsing (3 hours)
- [ ] Create python_chunker.go file
- [ ] Implement traversePythonNode() function
- [ ] Add basic function extraction

## Phase 2: Advanced Features (4 hours)
Dependencies: Phase 1 complete
- [ ] Add class extraction
- [ ] Handle decorators
- [ ] Extract async functions
```

### 4. Implementation

**During implementation**:
- Check off tasks as you complete them
- Update design.md if architecture changes
- Add notes to "Lessons Learned" in tasks.md
- Create new tasks if you discover additional work

**After implementation**:
- Fill in "What Went Well" and "What Could Be Improved"
- Document any surprises or unexpected challenges
- Keep the feature spec as reference material

### 5. Archive

**After completion**:
- Feature specs remain in the repository as **historical documentation**
- New contributors can learn from past design decisions
- Future features can reference similar implementations
- "Lessons Learned" helps avoid repeating mistakes

## Example: Python Support Feature

### Directory Structure
```
docs/features/f001-python-support/
├── requirements.md    # Functional requirements, performance targets
├── design.md          # Architecture, components, Python AST node types
└── tasks.md           # 3 phases: core parsing, advanced features, testing
```

### Requirements.md (excerpt)
```markdown
## Key Functional Requirements

**Python Function Extraction (FR1)**: Extract all function definitions
- GIVEN a Python file with def statements
- WHEN ChunkCode() is called
- THEN functions are extracted with name, parameters, decorators

**Performance (P1)**: Parse 1000-line Python file in <2 seconds
**Coverage (C1)**: Support functions, classes, methods, async/await
```

### Design.md (excerpt)
```markdown
## Components

**PythonChunker** (pkg/chunker/python_chunker.go)
- traversePythonNode(): Walk Python AST
- extractPythonFunction(): Handle def statements
- extractPythonClass(): Handle class statements
- extractPythonDecorated(): Handle @decorator syntax

## Python AST Node Types
- function_definition → "function" chunk
- class_definition → "type" chunk (type_kind="class")
- decorated_definition → Check nested definition type
```

### Tasks.md (excerpt)
```markdown
## Phase 1: Core Infrastructure (2 hours)
- [x] Add go-tree-sitter/python dependency
- [x] Create python_chunker.go file
- [x] Implement basic traversal

## Lessons Learned
### What Went Well
- Tree-sitter Python grammar is well-documented
- Reused helper functions from go_chunker.go

### Surprises
- Async functions require special handling (async_function_definition node type)
- Decorators are separate nodes above function definitions
```

## Benefits of This Approach

1. **Clear communication**: Requirements are explicit, not assumed
2. **Better estimates**: Breaking work into phases improves time estimates
3. **Fewer surprises**: Design phase catches edge cases early
4. **Knowledge transfer**: New contributors can read past specs
5. **Decision records**: Design documents explain WHY choices were made
6. **Improved quality**: Testing approach planned upfront, not afterthought

## Anti-Patterns to Avoid

### ❌ Don't Write Specs After Implementation
```
# Bad: "Documentation" written after code is done
git commit -m "feat: add Python support"
# ... weeks later ...
"Oh, we should document how that works"
# Creates requirements.md post-hoc (loses design rationale)
```

### ❌ Don't Skip "Out of Scope" Section
```markdown
# Bad: Ambiguous scope
## Requirements
- Support Python functions
- Support Python classes

# Good: Explicit boundaries
## Requirements
- Support Python functions
- Support Python classes

## Out of Scope
- Type annotations parsing (future feature)
- Docstring extraction (separate concern)
- Python 2.x support (only Python 3.6+)
```

### ❌ Don't Use Vague Acceptance Criteria
```markdown
# Bad: Not testable
**Python Support (FR1)**: Parse Python code correctly

# Good: Specific and testable
**Python Function Extraction (FR1)**:
- GIVEN a .py file with 5 function definitions
- WHEN ChunkCode() is called
- THEN exactly 5 function chunks are returned
- AND each chunk has accurate start_line and end_line metadata
```

### ❌ Don't Ignore "Lessons Learned"
```markdown
# Bad: Empty section (missed learning opportunity)
## Lessons Learned
(none)

# Good: Capture insights
## Lessons Learned
### What Went Well
- Reusing tree-sitter patterns from Go chunker saved 4 hours
- Test fixtures from Python stdlib were excellent edge cases

### What Could Be Improved
- Should have researched Python AST node types before coding
- Decorators were more complex than expected, should have asked earlier

### Surprises
- Python async functions use different AST node type (async_function_definition)
- Nested functions are extracted separately (should they be child chunks?)
```

## Template Customization Guidelines

### For Simple Features (<4 hours, clear requirements)

**Use**: `design.md` only

**Skip**: `requirements.md` (obvious), `tasks.md` (too small to break down)

**Example**: "Add logging to SaveChunks method"

### For Medium Features (4-16 hours, some ambiguity)

**Use**: `requirements.md` + `design.md`

**Skip**: `tasks.md` (can track in GitHub Issues instead)

**Example**: "Add JavaScript language support" (similar to existing Go support)

### For Complex Features (16+ hours, many unknowns)

**Use**: All three documents

**Reason**: Need clear scope, detailed design, and task tracking

**Example**: "Implement pgvector embedding storage layer" (new domain, database schema changes, integration with external services)

## Questions?

- **How detailed should requirements be?** → Detailed enough that someone else could implement without asking questions
- **Can I update design during implementation?** → Yes! Design is iterative. Update if you discover better approaches.
- **Should I create GitHub Issues too?** → Optional. Use Issues for tracking, use feature specs for design rationale.
- **What if requirements change mid-implementation?** → Update requirements.md, note the change in tasks.md "Lessons Learned"

## Related Documentation

- **Product Vision**: See [../constitution/product.md](../constitution/product.md) for overall scope and roadmap
- **Technical Standards**: See [../constitution/tech.md](../constitution/tech.md) for architecture patterns
- **Coding Conventions**: See [../conventions.md](../conventions.md) for Go-specific practices
- **Development Guide**: See [../../CLAUDE.md](../../CLAUDE.md) for quick reference

---

**Remember**: The goal is to ship high-quality features efficiently, not to create documentation for its own sake. Use these templates as tools, not bureaucracy.
