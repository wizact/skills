# Code-Chunker Conventions

This document outlines Go-specific coding standards, testing practices, and patterns used in code-chunker. Follow these conventions for consistency and maintainability.

## Table of Contents

1. [Go Code Conventions](#go-code-conventions)
2. [Testing Conventions](#testing-conventions)
3. [Error Handling](#error-handling)
4. [Package Organization](#package-organization)
5. [Interface Design](#interface-design)
6. [Git Workflow](#git-workflow)
7. [Extending Languages](#extending-languages)

---

## Go Code Conventions

### Filenames

All Go source files must follow these naming conventions:

- **All lowercase**: Filenames should be entirely lowercase
- **Use underscores**: Separate words with underscores (`_`) rather than hyphens or camelCase
- **No spaces**: Never use spaces in filenames
- **Descriptive names**: Use clear, descriptive names that indicate the file's purpose

**Examples**:
- ✅ `user_service.go`
- ✅ `http_client.go`
- ✅ `database_connection.go`
- ✅ `auth_middleware.go`
- ✅ `go_chunker.go` (language-specific chunker)
- ❌ `UserService.go` (uppercase)
- ❌ `http-client.go` (hyphens)
- ❌ `database connection.go` (spaces)

**Special cases**:
- **Test files**: Add `_test.go` suffix (e.g., `user_service_test.go`, `go_chunker_test.go`)
- **Build constraints**: May include OS/arch in filename (e.g., `file_unix.go`, `file_windows.go`)

### Package Names

- **Lowercase**: Package names should be lowercase, singular words
- **Match directory**: Package name should match the directory name
- **No underscores**: Use single words without underscores (e.g., `chunker`, not `code_chunker`)
- **Descriptive**: Clear purpose (e.g., `storage`, `chunker`, not `utils`, `common`)

**Examples**:
```
pkg/chunker/   → package chunker
pkg/storage/   → package storage
cmd/chunker/   → package main
```

### Interface Naming

- **Descriptive names**: Clearly indicate the interface's purpose
- **-er or -or suffix**: Use conventional suffixes (e.g., `Reader`, `Writer`, `Chunker`, `Parser`)
- **Exceptions**: Common patterns like `Storage` are acceptable

**Examples**:
- ✅ `ChunkStorage` (storage for chunks)
- ✅ `CodeChunker` (chunks code)
- ✅ `Parser` (parses input)
- ❌ `IStorage` (Go doesn't use `I` prefix)
- ❌ `StorageInterface` (redundant suffix)

### Error Variables

- **Prefix with Err**: Error variables should start with `Err`
- **Exported errors**: Use `Err` prefix for package-level sentinel errors
- **CamelCase**: Follow standard Go naming (e.g., `ErrNotFound`, `ErrInvalidInput`)

**Examples**:
```go
var (
    ErrNotFound      = errors.New("chunk not found")
    ErrInvalidInput  = errors.New("invalid input")
    ErrDatabaseError = errors.New("database error")
)
```

---

## Testing Conventions

### Libraries

All tests must use the following libraries:

- **Assertions**: `github.com/stretchr/testify/assert` and `github.com/stretchr/testify/require`
  - Use `assert` for non-critical assertions (test continues on failure)
  - Use `require` when subsequent tests depend on the assertion passing (test stops on failure)
- **Mocking**: `github.com/golang/mock/gomock` for interface mocking
- **Test Data**: Use `testdata/` directory for sample files

### Test Structure

**Table-driven tests with subtests**:

```go
func TestExtractGoFunction(t *testing.T) {
    tests := []struct {
        name          string
        source        string
        expectedName  string
        expectedType  string
    }{
        {
            name:         "simple function",
            source:       "func hello() {}",
            expectedName: "hello",
            expectedType: "function",
        },
        {
            name:         "function with parameters",
            source:       "func add(a, b int) int { return a + b }",
            expectedName: "add",
            expectedType: "function",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            chunks := parseGoCode(tt.source)
            require.Len(t, chunks, 1, "should extract one chunk")
            assert.Equal(t, tt.expectedName, chunks[0].Name)
            assert.Equal(t, tt.expectedType, chunks[0].Type)
        })
    }
}
```

### Test Naming

- **Test functions**: Prefix with `Test` followed by the function/method name
  - `TestChunkCode`, `TestExtractGoFunction`, `TestSaveChunks`
- **Test case names**: Descriptive strings that explain what is being tested
  - "simple function", "method with receiver", "empty input"
- **Avoid generic names**: "test 1", "test 2", "basic test"

### Test Helpers

**Create helper functions** to reduce repetition:

```go
// parseGoCode is a helper that parses Go source code and returns chunks
func parseGoCode(source string) []chunker.CodeChunk {
    cc := chunker.NewCodeChunker([]byte(source), golang.GetLanguage())
    chunks, _ := cc.ChunkCode(context.Background())
    return chunks
}

// getChunksByType filters chunks by type
func getChunksByType(chunks []chunker.CodeChunk, chunkType string) []chunker.CodeChunk {
    var filtered []chunker.CodeChunk
    for _, c := range chunks {
        if c.Type == chunkType {
            filtered = append(filtered, c)
        }
    }
    return filtered
}

// assertChunk asserts common chunk properties
func assertChunk(t *testing.T, chunk chunker.CodeChunk, name, chunkType string) {
    assert.Equal(t, name, chunk.Name)
    assert.Equal(t, chunkType, chunk.Type)
    assert.NotEmpty(t, chunk.Content)
}
```

### Test Data Organization

- **testdata/ directory**: Place test data files in `testdata/` subdirectory next to test files
- **Descriptive filenames**: Use clear names that indicate the test scenario
- **Multiple files**: Organize by feature or language construct

**Example structure**:
```
pkg/chunker/
├── go_chunker.go
├── go_chunker_test.go
└── testdata/
    ├── simple_function.go          # Basic function test
    ├── method_with_receiver.go     # Method parsing test
    ├── type_declarations.go        # Type extraction test
    ├── complex_nested.go           # Nested structures test
    └── README.md                   # Describes test fixtures
```

### Assert vs Require

**Use `assert` for soft failures** (test continues):
```go
assert.Equal(t, "hello", chunk.Name)
assert.NotEmpty(t, chunk.Content)
// Test continues even if these fail
```

**Use `require` for hard failures** (test stops immediately):
```go
chunks, err := cc.ChunkCode(ctx)
require.NoError(t, err, "parsing should not fail")
require.Len(t, chunks, 1, "should have exactly one chunk")
// If these fail, subsequent assertions would panic, so stop here
```

---

## Error Handling

### Error Wrapping

**Always wrap errors with context** using `fmt.Errorf` with `%w`:

```go
// Good: Wraps error with context
if err != nil {
    return nil, fmt.Errorf("failed to parse Go code: %w", err)
}

// Good: Multiple context layers
if err := store.SaveChunks(ctx, chunks, filePath, lang, gitHash); err != nil {
    return 0, fmt.Errorf("failed to save chunks for %s: %w", filePath, err)
}

// Bad: Returns raw error (loses context)
if err != nil {
    return nil, err
}

// Bad: Uses %v instead of %w (can't unwrap with errors.Is/As)
if err != nil {
    return nil, fmt.Errorf("failed: %v", err)
}
```

### Error Checking with errors.Is and errors.As

Use `%w` wrapping to enable error inspection:

```go
err := store.GetLatestChunks(ctx, "main.go")
if errors.Is(err, sql.ErrNoRows) {
    // Handle "not found" case
    return []chunker.CodeChunk{}, nil
}

var pgErr *pq.Error
if errors.As(err, &pgErr) {
    // Handle PostgreSQL-specific error
    log.Printf("PostgreSQL error code: %s", pgErr.Code)
}
```

### Guard Clauses (Early Returns)

**Return early on errors** to avoid deep nesting:

```go
// Good: Guard clause with early return
func (cc *CodeChunker) getNodeText(node *sitter.Node) string {
    if node == nil {
        return ""
    }

    // Proceed with logic
    return string(cc.source[node.StartByte():node.EndByte()])
}

// Bad: Nested if statements
func (cc *CodeChunker) getNodeText(node *sitter.Node) string {
    if node != nil {
        text := string(cc.source[node.StartByte():node.EndByte()])
        return text
    }
    return ""
}
```

**Check nil before dereferencing**:

```go
// Good: Nil check before access
if node == nil {
    return ""
}
text := cc.getNodeText(node)

// Bad: Potential nil pointer dereference
text := cc.getNodeText(node)  // Panics if node is nil
```

---

## Package Organization

### Directory Structure

- **Public APIs in pkg/**: Exportable libraries used by external projects
- **Internal-only code in internal/**: Code that can't be imported by external projects
- **One package per directory**: Each directory should contain one Go package
- **Avoid circular dependencies**: Use dependency inversion (interfaces) to break cycles

**Standard Go project layout**:
```
project-root/
├── cmd/              # Command-line applications
│   ├── myapp/        # Main application
│   └── tool/         # Additional tools
├── internal/         # Private application code (module-root level)
│   ├── api/          # HTTP/gRPC handlers
│   ├── cli/          # CLI implementation
│   └── service/      # Business logic
├── pkg/              # Public library code (can be imported by external projects)
│   ├── domain/       # Domain models
│   └── client/       # Client library
├── docs/             # Documentation
├── migrations/       # Database migrations (if applicable)
└── go.mod
```

### The `internal/` Directory: Placement and Purpose

**Rule: Place `internal/` at the module root, alongside `pkg/` and `cmd/`**

The `internal/` directory is a special Go convention that prevents external imports. Go's import rules enforce that packages under `internal/` can only be imported by code in the same module tree at or above the `internal/` directory.

#### ✅ Correct Placement (Module Root)

```
github.com/yourorg/yourproject/
├── cmd/
│   └── myapp/
│       └── main.go           # Imports internal/cli, internal/api
├── internal/                 # ← At module root
│   ├── api/
│   │   ├── handlers.go
│   │   └── middleware.go
│   ├── cli/
│   │   ├── root.go
│   │   └── commands.go
│   └── service/
│       └── business_logic.go
└── pkg/
    └── domain/

Import path: github.com/yourorg/yourproject/internal/cli
```

**Benefits**:
- Clean, predictable import paths
- Follows Go community standards (used by kubernetes, docker, prometheus, etc.)
- Clear separation: `internal/` alongside `pkg/` shows public vs. private code
- Easier to understand project structure at a glance

#### ❌ Incorrect Placement (Nested in cmd/)

```
github.com/yourorg/yourproject/
├── cmd/
│   └── myapp/
│       ├── internal/         # ← Nested (non-standard)
│       │   └── handlers/
│       │       └── http.go
│       └── main.go
└── pkg/

Import path: github.com/yourorg/yourproject/cmd/myapp/internal/handlers
```

**Problems**:
- Confusing import paths with redundant directory nesting
- Non-standard structure (violates Go community conventions)
- Harder for new contributors to understand project organization
- Makes code harder to move or refactor
- Limits reusability across multiple cmd/ binaries

#### When to Use `internal/` vs. `pkg/`

**Use `pkg/`** for code that:
- ✅ Should be importable by other projects
- ✅ Provides stable, documented public APIs
- ✅ Is designed for reuse (libraries, frameworks)
- ✅ Example: `pkg/client` - SDK for external consumers

**Use `internal/`** for code that:
- ✅ Is specific to this application only
- ✅ Should NOT be imported by external projects
- ✅ Can change without affecting external users
- ✅ Contains business logic, handlers, implementation details
- ✅ Example: `internal/api` - HTTP handlers for this service

**Use `cmd/` packages** (not `internal/`) for:
- ✅ Main entry points (`package main`)
- ✅ Minimal glue code that wires together `pkg/` and `internal/`
- ✅ Example: `cmd/myapp/main.go` - just initializes and starts the app

#### Real-World Example

**Before (Incorrect)**:
```go
// cmd/myapp/main.go
import "github.com/yourorg/yourproject/cmd/myapp/internal/handlers"

func main() {
    handlers.Start()  // Confusing: nested path
}
```

**After (Correct)**:
```go
// cmd/myapp/main.go
import "github.com/yourorg/yourproject/internal/api"

func main() {
    api.Start()  // Clear: internal API package
}
```

#### Multiple Binaries Sharing Code

When you have multiple binaries (`cmd/server`, `cmd/cli`, `cmd/worker`), they can all share `internal/` code:

```
github.com/yourorg/yourproject/
├── cmd/
│   ├── server/
│   │   └── main.go       # Imports internal/api, internal/service
│   ├── cli/
│   │   └── main.go       # Imports internal/cli, internal/service
│   └── worker/
│       └── main.go       # Imports internal/service
├── internal/             # Shared by all cmd/ binaries
│   ├── api/              # Used by cmd/server
│   ├── cli/              # Used by cmd/cli
│   └── service/          # Used by all binaries
└── pkg/
    └── client/           # Public client library
```

This is **only possible** with module-root `internal/`. Nested `cmd/{app}/internal/` would not be accessible to other binaries.

#### Key Takeaways

1. **Module-root placement**: Always put `internal/` at the module root
2. **Alongside `pkg/`**: Keep `internal/` and `pkg/` at the same level for clarity
3. **Descriptive names**: Use meaningful package names under `internal/` (e.g., `internal/api`, `internal/service`, `internal/repository`)
4. **No nesting**: Avoid `cmd/{app}/internal/` - use module-root `internal/` instead
5. **Share across binaries**: Module-root `internal/` can be imported by all `cmd/` binaries
6. **Check conventions**: Look at standard Go projects (kubernetes, prometheus, docker, hugo) for reference

### Import Organization

**Group imports** in this order:
1. Standard library
2. External dependencies
3. Internal packages

```go
import (
    // Standard library
    "context"
    "fmt"
    "strings"

    // External dependencies
    "github.com/smacker/go-tree-sitter/golang"
    "github.com/stretchr/testify/assert"

    // Internal packages
    "github.com/wizact/code-chunker/pkg/chunker"
)
```

### Avoid Circular Dependencies

**Use interfaces to break cycles**:

```go
// Bad: storage imports chunker, chunker imports storage (circular)
// chunker/code_chunk.go
import "github.com/wizact/code-chunker/pkg/storage"
func (cc *CodeChunker) Save(store *storage.PostgresStore) error { ... }

// Good: storage imports chunker, chunker doesn't import storage
// chunker/code_chunk.go
// No import of storage package needed
func (cc *CodeChunker) ChunkCode() ([]CodeChunk, error) { ... }

// cmd/chunker/main.go
import (
    "github.com/wizact/code-chunker/pkg/chunker"
    "github.com/wizact/code-chunker/pkg/storage"
)
chunks, _ := cc.ChunkCode()
store.SaveChunks(ctx, chunks, filePath, lang, gitHash)
```

---

## Interface Design

### Small Interfaces (1-5 methods)

**Prefer focused interfaces** with minimal methods:

```go
// Good: Small, focused interface
type ChunkStorage interface {
    SaveChunks(ctx context.Context, chunks []CodeChunk, filePath, language, gitHash string) (int, error)
    GetLatestChunks(ctx context.Context, filePath string) ([]CodeChunk, error)
    GetChunksByVersion(ctx context.Context, filePath string, version int) ([]CodeChunk, error)
    GetChunksByGitHash(ctx context.Context, gitHash string) ([]CodeChunk, error)
    Close() error
}

// Bad: Too many methods, mixed concerns
type Storage interface {
    // Chunk operations
    SaveChunks(...) error
    GetChunks(...) ([]CodeChunk, error)
    DeleteChunks(...) error

    // Embedding operations (different concern)
    SaveEmbeddings(...) error
    GetEmbeddings(...) ([]float32, error)

    // Operational concerns (should be separate)
    Migrate() error
    Backup() error
    Restore() error
}
```

### Document All Parameters and Return Values

**Use godoc comments** for all exported interfaces and methods:

```go
// ChunkStorage defines the interface for persisting code chunks with versioning.
//
// Implementations must ensure:
//   - Thread safety for concurrent access
//   - Transaction safety (all-or-nothing saves)
//   - Auto-incrementing version numbers per file path
type ChunkStorage interface {
    // SaveChunks stores code chunks and returns the assigned version number.
    //
    // Parameters:
    //   ctx: Context for cancellation and deadlines
    //   chunks: Code chunks to save (must not be empty)
    //   filePath: Path to source file (e.g., "main.go", "src/utils.py")
    //   language: Language name (e.g., "go", "python")
    //   gitHash: Optional git commit SHA (empty string if not available)
    //
    // Returns:
    //   version: Auto-incremented version number for this file path
    //   error: Validation errors, database errors, or context cancellation
    //
    // Example:
    //   version, err := store.SaveChunks(ctx, chunks, "main.go", "go", "abc123")
    //   if err != nil {
    //       log.Fatalf("Failed to save: %v", err)
    //   }
    //   log.Printf("Saved as version %d", version)
    SaveChunks(ctx context.Context, chunks []CodeChunk, filePath, language, gitHash string) (int, error)

    // GetLatestChunks retrieves all chunks for the latest version of a file.
    //
    // Parameters:
    //   ctx: Context for cancellation and deadlines
    //   filePath: Path to source file
    //
    // Returns:
    //   chunks: All chunks from the latest version (empty slice if file not found)
    //   error: Database errors or context cancellation
    GetLatestChunks(ctx context.Context, filePath string) ([]CodeChunk, error)

    // Close releases any resources held by the storage implementation.
    //
    // Returns:
    //   error: Resource cleanup errors (e.g., database connection close failure)
    Close() error
}
```

### Accept Interfaces, Return Structs

**Accept interfaces in function parameters** (caller flexibility):
```go
// Good: Accepts interface (caller can pass any implementation)
func ProcessChunks(ctx context.Context, store ChunkStorage, filePath string) error {
    chunks, err := store.GetLatestChunks(ctx, filePath)
    // ...
}

// Bad: Accepts concrete type (locks caller to PostgreSQL)
func ProcessChunks(ctx context.Context, store *PostgresStore, filePath string) error {
    chunks, err := store.GetLatestChunks(ctx, filePath)
    // ...
}
```

**Return concrete structs** (implementation clarity):
```go
// Good: Returns concrete type
func (cc *CodeChunker) ChunkCode(ctx context.Context) ([]CodeChunk, error) {
    // ... return []CodeChunk, not interface{}
}
```

---

## Git Workflow

### Signed Commits

**Always sign commits** with the `-S` flag:

```bash
git commit -S -m "feat: add Python language support"
git commit -S -m "fix: handle nil node in getNodeText"
```

**Configure GPG signing**:
```bash
# Set up GPG key for signing
git config --global user.signingkey <YOUR_GPG_KEY_ID>

# Enable commit signing by default (optional)
git config --global commit.gpgsign true
```

### Worktrees for Parallel Work

**Use git worktrees** for parallel feature development:

```bash
# Create worktree for feature branch
git worktree add ../code-chunker-python python-support

# Work in the new directory
cd ../code-chunker-python
# ... make changes, commit, push ...

# Return to main worktree
cd ../code-chunker

# Remove worktree when done
git worktree remove ../code-chunker-python
```

**Benefits**:
- Work on multiple branches simultaneously
- No need to stash or commit WIP changes when switching contexts
- Each worktree has its own working directory

### Conventional Commits

**Use conventional commit format** for clear history:

```bash
# Features
git commit -S -m "feat: add Python language support"
git commit -S -m "feat(storage): add embedding storage with pgvector"

# Bug fixes
git commit -S -m "fix: handle nil node in AST traversal"
git commit -S -m "fix(db): correct version increment logic"

# Documentation
git commit -S -m "docs: update README with Python examples"
git commit -S -m "docs(api): add godoc comments to ChunkStorage"

# Refactoring
git commit -S -m "refactor: extract language dispatch to separate function"

# Tests
git commit -S -m "test: add table-driven tests for Python chunker"

# Build/CI
git commit -S -m "build: update Go version to 1.23"
git commit -S -m "ci: add PostgreSQL service for integration tests"
```

**Format**: `<type>(<optional scope>): <description>`

**Common types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring (no behavior change)
- `test`: Adding or updating tests
- `build`: Build system changes
- `ci`: CI/CD configuration changes

### Test Locally Before Pushing

**Always run checks before pushing**:

```bash
# Format code
make fmt

# Run linters
make lint

# Run tests
make test

# Build binaries
make build
```

**Or run all at once**:
```bash
make fmt && make lint && make test && make build
```

---

## Extending Languages

### Adding a New Language (Python, JavaScript, etc.)

Follow these steps to add support for a new language:

#### 1. Add tree-sitter Grammar Dependency

**Add to `go.mod`**:
```bash
go get github.com/smacker/go-tree-sitter/python
```

**Import in code**:
```go
import (
    "github.com/smacker/go-tree-sitter/python"
)
```

#### 2. Create `{language}_chunker.go` File

**Create** `pkg/chunker/python_chunker.go`:

```go
package chunker

import (
    sitter "github.com/smacker/go-tree-sitter"
)

// chunkPythonCode extracts chunks from Python source code
func (cc *CodeChunker) chunkPythonCode(root *sitter.Node) []CodeChunk {
    var chunks []CodeChunk
    cc.traversePythonNode(root, &chunks)
    return chunks
}

// traversePythonNode recursively walks the Python AST
func (cc *CodeChunker) traversePythonNode(node *sitter.Node, chunks *[]CodeChunk) {
    if node == nil {
        return
    }

    switch node.Type() {
    case "function_definition":
        cc.extractPythonFunction(node, chunks)
    case "class_definition":
        cc.extractPythonClass(node, chunks)
    case "decorated_definition":
        cc.extractPythonDecorated(node, chunks)
    }

    // Recurse into children
    for i := 0; i < int(node.ChildCount()); i++ {
        child := node.Child(i)
        cc.traversePythonNode(child, chunks)
    }
}

// extractPythonFunction extracts a Python function definition
func (cc *CodeChunker) extractPythonFunction(node *sitter.Node, chunks *[]CodeChunk) {
    name := cc.findChildByType(node, "identifier")
    if name == nil {
        return
    }

    chunk := CodeChunk{
        Content:  cc.getNodeText(node),
        Type:     "function",
        Name:     cc.getNodeText(name),
        Metadata: cc.getBasicMetadata(node),
    }

    // Add Python-specific metadata
    if decorators := cc.findChildByType(node, "decorator"); decorators != nil {
        chunk.Metadata["decorators"] = cc.getNodeText(decorators)
    }

    *chunks = append(*chunks, chunk)
}

// extractPythonClass extracts a Python class definition
func (cc *CodeChunker) extractPythonClass(node *sitter.Node, chunks *[]CodeChunk) {
    // Similar to extractPythonFunction...
}
```

#### 3. Update Dispatcher in `code_chunk.go`

**Add language check** to `ChunkCode()` method:

```go
func (cc *CodeChunker) ChunkCode(ctx context.Context) ([]CodeChunk, error) {
    root := cc.rootNode

    if cc.lang == *golang.GetLanguage() {
        chunks := cc.chunkGoCode(root)
        return chunks, nil
    }

    // Add Python support
    if cc.lang == *python.GetLanguage() {
        chunks := cc.chunkPythonCode(root)
        return chunks, nil
    }

    return nil, fmt.Errorf("unsupported language: %v", cc.lang)
}
```

#### 4. Write Table-Driven Tests

**Create** `pkg/chunker/python_chunker_test.go`:

```go
package chunker

import (
    "context"
    "testing"

    "github.com/smacker/go-tree-sitter/python"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestChunkPythonCode(t *testing.T) {
    tests := []struct {
        name          string
        source        string
        expectedCount int
        expectedType  string
    }{
        {
            name:          "simple function",
            source:        "def hello():\n    pass",
            expectedCount: 1,
            expectedType:  "function",
        },
        {
            name:          "class with method",
            source:        "class Person:\n    def greet(self):\n        pass",
            expectedCount: 2,  // class + method
            expectedType:  "class",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            chunks := parsePythonCode(tt.source)
            require.Len(t, chunks, tt.expectedCount)
            assert.Equal(t, tt.expectedType, chunks[0].Type)
        })
    }
}

// Helper function
func parsePythonCode(source string) []CodeChunk {
    cc := NewCodeChunker([]byte(source), python.GetLanguage())
    chunks, _ := cc.ChunkCode(context.Background())
    return chunks
}
```

#### 5. Add Test Fixtures to `testdata/`

**Create** test files in `pkg/chunker/testdata/`:

```
testdata/
├── python_simple_function.py
├── python_class_definition.py
├── python_decorated_function.py
└── README.md (update with new files)
```

**Example fixture** (`python_simple_function.py`):
```python
def hello(name):
    """Greet someone by name."""
    print(f"Hello, {name}!")
```

#### 6. Update README.md

**Add Python to supported languages** section in `README.md`:

```markdown
## Features

- **Multi-language support**: Go, Python (more languages coming)
- ...
```

**Add Python examples** if needed.

### Language-Specific Metadata

Use the `Metadata` map for language-specific attributes:

**Go**:
- `receiver`: `"(p *Person)"` for methods
- `type_kind`: `"struct"`, `"interface"`, `"map"` for types

**Python** (suggested):
- `decorators`: `"@staticmethod @cache"` for decorated functions
- `async`: `"true"` for async functions
- `class_bases`: `"BaseClass, Mixin"` for class inheritance

**JavaScript** (suggested):
- `async`: `"true"` for async functions
- `arrow_function`: `"true"` for arrow functions
- `export`: `"default"` or `"named"` for exports

### Testing Your Language Implementation

**Run tests**:
```bash
# Test Python chunker specifically
go test -v ./pkg/chunker/ -run TestChunkPythonCode

# Test all chunkers
go test -v ./pkg/chunker/

# With coverage
go test -cover ./pkg/chunker/
```

**Verify**:
- All chunk types are extracted (functions, classes, methods, etc.)
- Metadata is accurate (line numbers, byte offsets)
- Edge cases are handled (nested definitions, decorators, etc.)
- No panics on malformed input

---

## Summary

**Key principles**:
1. **Consistency**: Follow established patterns (filenames, error handling, testing)
2. **Clarity**: Use descriptive names, document interfaces, write clear tests
3. **Safety**: Wrap errors, check nil, use guard clauses
4. **Testability**: Table-driven tests, helpers, real database for integration tests
5. **Extensibility**: Small interfaces, language dispatch pattern, JSONB metadata

For more details:
- **Architecture**: See [CLAUDE.md](../CLAUDE.md)
- **Product Vision**: See [constitution/product.md](constitution/product.md)
- **Technical Decisions**: See [constitution/tech.md](constitution/tech.md)
