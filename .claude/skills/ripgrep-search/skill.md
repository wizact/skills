---
name: ripgrep-search
description: Ultra-fast text search using ripgrep (rg) with advanced regex, multiline, and filtering capabilities. This skill should be used as a replacement for `grep`
---

# Ripgrep Search Skill

You are a specialized assistant for ultra-fast text searching using **ripgrep (rg)** - a blazing fast grep replacement that combines speed, Unicode support, and powerful features. Your expertise focuses on leveraging ripgrep's advanced capabilities to help users find patterns in text with exceptional performance and sophisticated filtering options.

> **Reference Guide**: For comprehensive examples, command patterns, and troubleshooting, see @.claude/skills/ripgrep-search/REFERENCE.md

## Core Capabilities

1. **Lightning-fast text search** with regex and literal patterns
2. **Unicode-aware searching** with full UTF-8 support
3. **Advanced filtering** by file types, sizes, dates, and gitignore rules
4. **Multiline pattern matching** for complex searches
5. **Parallel processing** with automatic multi-threading
6. **Context-aware output** with before/after line context
7. **JSON output** for structured processing
8. **PCRE2 regex support** for advanced patterns

## Quick Start Scripts

This skill includes 6 essential scripts for the most common text search tasks:

1. **search-code.sh** - Search in source code files with smart filtering
2. **search-logs.sh** - Search log files with timestamp and error filtering
3. **search-multiline.sh** - Multi-line pattern matching
4. **search-replace.sh** - Find and replace patterns with preview
5. **search-context.sh** - Search with configurable context lines
6. **search-stats.sh** - Generate search statistics and reports

Usage: `@.claude/skills/ripgrep-search/scripts/script-name.sh --help` for each script.

## Key Advantages Over `grep`

- **10-100x faster**: Parallel processing and optimized algorithms
- **Smart defaults**: Respects .gitignore, skips binary files automatically
- **Unicode support**: Full UTF-8 support without performance penalty
- **Advanced regex**: Support for both Rust regex and PCRE2 engines
- **Rich output**: Colors, line numbers, file names, context
- **File type awareness**: Built-in file type detection and filtering
- **Memory efficient**: Uses memory mapping for large files

## Core Commands

### Basic Search Patterns

#### Simple Text Search
```bash
# Basic pattern search
rg "function"                 # Find 'function' in current directory
rg "error" /var/log          # Search in specific directory
rg "TODO|FIXME"              # Multiple patterns (OR)

# Case sensitivity control
rg -i "Error"                # Case-insensitive search
rg -s "Error"                # Case-sensitive search (override smart case)

# Word boundaries
rg -w "log"                  # Match whole word only
rg "\blog\b"                 # Explicit word boundary regex
```

#### Regex Patterns
```bash
# Basic regex (default engine)
rg "^ERROR.*network"         # Lines starting with ERROR containing network
rg "\d{3}-\d{3}-\d{4}"      # Phone number pattern
rg "fn\s+\w+\s*\("          # Function definitions

# PCRE2 advanced regex (when needed)
rg -P "(?<=Error: )\w+"      # Positive lookbehind
rg -P "(?!test_)\w+\.py"     # Negative lookahead
rg -P "\K(?<=id=)\d+"        # Keep groups
```

#### Literal Search
```bash
# Fixed string search (faster for literals)
rg -F "exact.string"         # No regex interpretation
rg -F "special$chars"        # Search for literal special characters
rg -F -w "class"             # Literal word match
```

### File Type and Path Filtering

#### File Type Filtering
```bash
# By file extension
rg "pattern" -t py           # Python files only
rg "pattern" -t js -t ts     # JavaScript and TypeScript
rg "pattern" -T json         # Exclude JSON files

# Custom file types (see rg --type-list)
rg "pattern" -t rust         # Rust source files
rg "pattern" -t cpp          # C++ files
rg "pattern" -t web          # Web files (html, css, js)

# Multiple type combinations
rg "TODO" -t py -t rust -t go # Search in multiple languages
```

#### Path and Name Filtering
```bash
# Glob patterns for paths
rg "pattern" -g "*.log"      # Log files only
rg "pattern" -g "!*.min.js"  # Exclude minified JS
rg "pattern" -g "src/**"     # Only in src directory tree

# Path-based filtering
rg "pattern" --iglob "*test*" # Include test files
rg "pattern" --iglob "!*node_modules*" # Exclude node_modules
```

### Advanced Search Options

#### Context and Output Control
```bash
# Context lines
rg -A 3 "error"              # 3 lines after match
rg -B 2 "function"           # 2 lines before match
rg -C 5 "pattern"            # 5 lines before and after

# Line numbers and positioning
rg -n "pattern"              # Show line numbers (default)
rg --no-line-number "pattern" # Hide line numbers
rg --column "pattern"        # Show column numbers

# Output formatting
rg --no-filename "pattern"   # Hide filenames
rg --with-filename "pattern" # Force show filenames
rg -H "pattern"              # Always show filenames
```

#### Multiline Search
```bash
# Enable multiline mode
rg -U "start.*\n.*end"       # Pattern spanning lines
rg -U "function.*?\n.*return" # Function with return
rg -U "class \w+:.*?\n.*def" # Class with method

# Null separator (binary safe)
rg -0 "pattern"              # Use null separators
```

#### Search Scope Control
```bash
# Depth control
rg --max-depth 3 "pattern"   # Limit directory depth
rg --max-depth 1 "pattern"   # Current directory only

# File size limits
rg --max-filesize 1M "pattern" # Skip files larger than 1MB

# Include/exclude hidden and ignored files
rg -. "pattern"              # Include hidden files
rg --no-ignore "pattern"     # Ignore .gitignore rules
rg -u "pattern"              # Include hidden and ignored files
```

### Output Formats and Processing

#### Structured Output
```bash
# JSON output for processing
rg --json "pattern"          # JSON lines format
rg --json "pattern" | jq     # Process with jq

# Count and statistics
rg -c "pattern"              # Count matches per file
rg --count-matches "pattern" # Count total matches
rg --files-with-matches "pattern" # List files with matches only
rg --files-without-match "pattern" # List files without matches
```

#### Replacement and Transformation
```bash
# Show replacements (preview)
rg "old" --replace "new"     # Show what replacement would look like
rg "(\w+)" --replace "[$1]"  # Use capture groups

# Passthrough mode
rg "pattern" --passthru      # Show all lines, highlight matches
rg "error" --passthru -A 0 -B 0  # Highlight in context
```

## Performance-Oriented Usage

### High-Performance Patterns
```bash
# Parallel processing (automatic by default)
rg -j 8 "pattern"            # Force 8 threads (usually auto-detected)

# Memory mapping control
rg --mmap "pattern"          # Force memory mapping
rg --no-mmap "pattern"       # Force read() calls

# Optimized for specific use cases
rg --max-count 1 "pattern"   # Stop after first match per file
rg -l "pattern"              # Files with matches (faster than full output)
```

### Smart Filtering for Speed
```bash
# Pre-filter by file type for better performance
rg "pattern" -t py           # Much faster than rg "pattern" | grep "\.py"

# Use literal search when possible
rg -F "literal.string"       # Faster than regex for exact matches

# Limit scope effectively
rg "pattern" src/            # Search specific directory
rg "pattern" -g "*.rs"       # Specific file pattern
```

## Common Use Cases

### Development Workflows

```bash
# Code analysis
rg "TODO|FIXME|HACK|XXX" -t py -t js -t rust  # Find code annotations
rg "console\.log|print\(" --type js --type py # Debug statements
rg "panic!|unwrap\(\)" -t rust                # Unsafe Rust patterns

# API and function discovery
rg "fn \w+\(" -t rust        # Rust function definitions
rg "def \w+\(" -t py         # Python function definitions
rg "function \w+\(" -t js    # JavaScript function definitions

# Configuration and secrets
rg -i "password|secret|key" -t json -t yaml -t toml  # Config files
rg "api[_-]?key" --ignore-case  # API key patterns
rg "localhost:\d+" -t py -t js   # Local development URLs
```

### Log Analysis

```bash
# Error hunting
rg "ERROR|FATAL|CRITICAL" -t log  # Error levels in logs
rg "error" -A 3 -B 1 -t log       # Errors with context
rg "5\d{2}" --type log            # HTTP 5xx errors

# Performance monitoring
rg "slow|timeout|latency" -i -t log  # Performance issues
rg "\d+ms|\d+s" -t log               # Timing information
rg "memory|cpu|disk" -i -t log       # Resource usage
```

### System Administration

```bash
# Configuration validation
rg "^\s*#" --invert-match -t conf  # Non-comment config lines
rg "^[^#]*password" -t conf        # Password settings (uncommented)

# Security auditing
rg -i "password.*=" -t sh -t py    # Hardcoded passwords
rg "chmod.*777|chmod.*666" -t sh   # Dangerous permissions
rg "sudo\s+\w+" -t sh              # Sudo usage patterns
```

### Data Processing

```bash
# CSV/TSV analysis
rg "^[^,]*,error," data.csv  # CSV lines with error in second column
rg "\t\w+\t" --only-matching data.tsv  # Extract middle TSV column

# JSON processing
rg '"error":\s*"[^"]*"' -t json  # Error messages in JSON
rg '"id":\s*\d+' --only-matching -t json  # Extract ID values
```

## Advanced Techniques

### Complex Pattern Matching
```bash
# Multiline function search
rg -U 'fn \w+\([^{]*\{[^}]*\}' -t rust  # Simple Rust functions

# State machine patterns
rg -A 5 'state.*=.*INIT' | rg -B 5 'transition'  # State transitions

# Cross-reference search
rg -l "import.*module" | xargs rg "module\."  # Find usage after import
```

### Integration with Other Tools
```bash
# Pipe to other commands
rg "pattern" -l | xargs wc -l    # Count lines in matching files
rg "error" --json | jq '.data.submatches[].match.text'  # Extract matches

# Combined with fd for file filtering
fd -e rs | xargs rg "unsafe"     # Search unsafe in Rust files
fd -t f | rg --files-from - "pattern"  # Use fd output as file list

# Integration with git
git ls-files | rg --files-from - "pattern"  # Search only tracked files
rg "pattern" $(git diff --name-only)  # Search only modified files
```

### Performance Analysis
```bash
# Benchmark different approaches
time rg "pattern" -t py          # Time Python file search
time rg "pattern" --mmap         # Time with memory mapping
time rg "pattern" --no-ignore    # Time without gitignore

# Memory usage monitoring
rg --stats "pattern"             # Show search statistics
rg --debug "pattern" 2>&1 | head # Debug information
```

## Best Practices

### Do:
- **Use file type filters** (`-t py`) for better performance
- **Leverage gitignore** for automatic irrelevant file exclusion
- **Use literal search** (`-F`) when you don't need regex
- **Combine with other tools** for complex workflows
- **Use context options** (`-A`, `-B`, `-C`) for better understanding
- **Take advantage of Unicode support** for international text

### Don't:
- **Don't use overly complex regex** when simple patterns suffice
- **Don't ignore performance implications** of multiline search (`-U`)
- **Don't search binary files** unnecessarily (ripgrep handles this automatically)
- **Don't forget about case sensitivity** rules (smart case is default)
- **Don't use ripgrep for single-file operations** where other tools are simpler

## Integration with Scripts

When creating scripts that use ripgrep:
1. **Error handling**: Check ripgrep exit codes (0 = found, 1 = not found, 2 = error)
2. **Output processing**: Use `--json` for structured data, `--only-matching` for extracts
3. **Performance tuning**: Use appropriate file type filters and scope limiting
4. **Safety checks**: Validate patterns and file paths
5. **User experience**: Provide progress indication for large searches

## Quick Script Examples

For immediate use, try these common scenarios:

```bash
# Search in source code
@.claude/skills/ripgrep-search/scripts/search-code.sh "function" rust

# Search logs for errors
@.claude/skills/ripgrep-search/scripts/search-logs.sh "ERROR" /var/log

# Multi-line pattern search
@.claude/skills/ripgrep-search/scripts/search-multiline.sh "class.*?\n.*def"

# Find and replace preview
@.claude/skills/ripgrep-search/scripts/search-replace.sh "old_name" "new_name"

# Search with context
@.claude/skills/ripgrep-search/scripts/search-context.sh "error" 3

# Generate search statistics
@.claude/skills/ripgrep-search/scripts/search-stats.sh "TODO" src/
```

Remember: ripgrep is designed for speed and accuracy. When in doubt, start with simple patterns and add complexity as needed. The tool's smart defaults (Unicode support, gitignore respect, parallel processing) make it immediately powerful without complex configuration.