#!/bin/bash

# Search with configurable context lines and smart highlighting
# Usage: search-context.sh <pattern> [context-lines] [directory] [options]

set -e

show_help() {
    cat << EOF
Search with configurable context lines and smart highlighting

Usage: $0 <pattern> [context-lines] [directory] [options]

Arguments:
    pattern         The pattern to search for (required)
    context-lines   Number of context lines around matches (default: 3)
    directory       Directory to search in (default: current directory)

Examples:
    $0 "error" 5                        # Show 5 lines of context
    $0 "function" 2 src/                # Search in src/ with 2 lines context
    $0 "TODO" 0 --type=py               # No context, Python files only
    $0 "import" 1 --before=3 --after=1 # Different before/after context

Context Examples:
    Context 0:      Show only matching lines
    Context 1:      Show 1 line before and after
    Context 3:      Show 3 lines before and after (good default)
    Context 5:      Show 5 lines before and after (detailed view)

Options:
    --help, -h              Show this help message
    --before=N, -B N        Show N lines before match (overrides context)
    --after=N, -A N         Show N lines after match (overrides context)
    --type=TYPE, -t TYPE    Limit to specific file type
    --glob=PATTERN, -g      Include files matching glob pattern
    --case-sensitive        Force case-sensitive search
    --literal, -F           Use literal/fixed string mode
    --word, -w              Match whole words only
    --count, -c             Show count of matches per file
    --files-only, -l        Show only files with matches
    --json                  Output in JSON format
    --max-count=N           Stop after N matches per file
    --passthru              Show all lines, highlight matches
    --heading               Group results by file (default)
    --no-heading            Don't group results by file
    --separator=TEXT        Custom separator between match groups

Display Options:
    --no-line-numbers       Hide line numbers
    --column                Show column numbers
    --stats                 Show search statistics at end
    --color=WHEN            Colorize output (auto, always, never)

Advanced Context:
    --context-separator     Custom separator for context blocks
    --max-filesize=SIZE     Skip files larger than SIZE
    --hidden                Include hidden files
    --follow                Follow symbolic links
EOF
}

# Default values
PATTERN=""
CONTEXT_LINES="3"
DIRECTORY="."
BEFORE_LINES=""
AFTER_LINES=""
FILE_TYPE=""
GLOB_PATTERN=""
CASE_SENSITIVE=false
LITERAL_MODE=false
WORD_MATCH=false
COUNT_ONLY=false
FILES_ONLY=false
JSON_OUTPUT=false
MAX_COUNT=""
PASSTHRU_MODE=false
SHOW_HEADING=true
SEPARATOR=""
SHOW_LINE_NUMBERS=true
SHOW_COLUMN=false
SHOW_STATS=false
COLOR_MODE="auto"
CONTEXT_SEPARATOR=""
MAX_FILESIZE=""
INCLUDE_HIDDEN=false
FOLLOW_LINKS=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --before=*|-B*)
            if [[ $1 == --before=* ]]; then
                BEFORE_LINES="${1#*=}"
            else
                BEFORE_LINES="$2"
                shift
            fi
            shift
            ;;
        --after=*|-A*)
            if [[ $1 == --after=* ]]; then
                AFTER_LINES="${1#*=}"
            else
                AFTER_LINES="$2"
                shift
            fi
            shift
            ;;
        --type=*)
            FILE_TYPE="${1#*=}"
            shift
            ;;
        --type|-t)
            FILE_TYPE="$2"
            shift 2
            ;;
        -t*)
            FILE_TYPE="${1#-t}"
            shift
            ;;
        --glob=*)
            GLOB_PATTERN="${1#*=}"
            shift
            ;;
        --glob|-g)
            GLOB_PATTERN="$2"
            shift 2
            ;;
        -g*)
            GLOB_PATTERN="${1#-g}"
            shift
            ;;
        --case-sensitive)
            CASE_SENSITIVE=true
            shift
            ;;
        --literal|-F)
            LITERAL_MODE=true
            shift
            ;;
        --word|-w)
            WORD_MATCH=true
            shift
            ;;
        --count|-c)
            COUNT_ONLY=true
            shift
            ;;
        --files-only|-l)
            FILES_ONLY=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --max-count=*)
            MAX_COUNT="${1#*=}"
            shift
            ;;
        --passthru)
            PASSTHRU_MODE=true
            shift
            ;;
        --heading)
            SHOW_HEADING=true
            shift
            ;;
        --no-heading)
            SHOW_HEADING=false
            shift
            ;;
        --separator=*)
            SEPARATOR="${1#*=}"
            shift
            ;;
        --no-line-numbers)
            SHOW_LINE_NUMBERS=false
            shift
            ;;
        --column)
            SHOW_COLUMN=true
            shift
            ;;
        --stats)
            SHOW_STATS=true
            shift
            ;;
        --color=*)
            COLOR_MODE="${1#*=}"
            shift
            ;;
        --context-separator=*)
            CONTEXT_SEPARATOR="${1#*=}"
            shift
            ;;
        --max-filesize=*)
            MAX_FILESIZE="${1#*=}"
            shift
            ;;
        --hidden)
            INCLUDE_HIDDEN=true
            shift
            ;;
        --follow)
            FOLLOW_LINKS=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$PATTERN" ]]; then
                PATTERN="$1"
            elif [[ "$CONTEXT_LINES" == "3" && "$1" =~ ^[0-9]+$ ]]; then
                CONTEXT_LINES="$1"
            elif [[ "$DIRECTORY" == "." ]]; then
                DIRECTORY="$1"
            else
                echo "Too many arguments" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$PATTERN" ]]; then
    echo "Error: Pattern is required" >&2
    echo "Use $0 --help for usage information" >&2
    exit 1
fi

# Check if directory exists
if [[ ! -d "$DIRECTORY" ]]; then
    echo "Error: Directory '$DIRECTORY' does not exist" >&2
    exit 1
fi

# Check if ripgrep is available
if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) is not installed or not in PATH" >&2
    exit 1
fi

# Validate context lines
if [[ ! "$CONTEXT_LINES" =~ ^[0-9]+$ ]]; then
    echo "Error: Context lines must be a number" >&2
    exit 1
fi

# Build ripgrep command
RG_CMD=("rg")

# Add the pattern
RG_CMD+=("$PATTERN")

# Add context options
if [[ -n "$BEFORE_LINES" && -n "$AFTER_LINES" ]]; then
    RG_CMD+=("-B" "$BEFORE_LINES" "-A" "$AFTER_LINES")
elif [[ -n "$BEFORE_LINES" ]]; then
    RG_CMD+=("-B" "$BEFORE_LINES")
elif [[ -n "$AFTER_LINES" ]]; then
    RG_CMD+=("-A" "$AFTER_LINES")
else
    RG_CMD+=("-C" "$CONTEXT_LINES")
fi

# Add file type if specified
if [[ -n "$FILE_TYPE" ]]; then
    RG_CMD+=("-t" "$FILE_TYPE")
fi

# Add glob pattern if specified
if [[ -n "$GLOB_PATTERN" ]]; then
    RG_CMD+=("-g" "$GLOB_PATTERN")
fi

# Add case sensitivity
if [[ "$CASE_SENSITIVE" == true ]]; then
    RG_CMD+=("-s")
fi

# Add literal mode if requested
if [[ "$LITERAL_MODE" == true ]]; then
    RG_CMD+=("-F")
fi

# Add word match if requested
if [[ "$WORD_MATCH" == true ]]; then
    RG_CMD+=("-w")
fi

# Add max count if specified
if [[ -n "$MAX_COUNT" ]]; then
    RG_CMD+=("--max-count" "$MAX_COUNT")
fi

# Add passthru mode if requested
if [[ "$PASSTHRU_MODE" == true ]]; then
    RG_CMD+=("--passthru")
fi

# Add output mode flags
if [[ "$COUNT_ONLY" == true ]]; then
    RG_CMD+=("-c")
elif [[ "$FILES_ONLY" == true ]]; then
    RG_CMD+=("-l")
elif [[ "$JSON_OUTPUT" == true ]]; then
    RG_CMD+=("--json")
else
    # Configure display options
    if [[ "$SHOW_LINE_NUMBERS" == true ]]; then
        RG_CMD+=("-n")
    else
        RG_CMD+=("--no-line-number")
    fi

    if [[ "$SHOW_COLUMN" == true ]]; then
        RG_CMD+=("--column")
    fi

    if [[ "$SHOW_HEADING" == true ]]; then
        RG_CMD+=("--heading")
    else
        RG_CMD+=("--no-heading")
    fi

    # Color mode
    RG_CMD+=("--color=$COLOR_MODE")
fi

# Add separator if specified
if [[ -n "$SEPARATOR" ]]; then
    RG_CMD+=("--field-match-separator" "$SEPARATOR")
fi

# Add context separator if specified
if [[ -n "$CONTEXT_SEPARATOR" ]]; then
    RG_CMD+=("--field-context-separator" "$CONTEXT_SEPARATOR")
fi

# Add max filesize if specified
if [[ -n "$MAX_FILESIZE" ]]; then
    RG_CMD+=("--max-filesize" "$MAX_FILESIZE")
fi

# Add hidden files if requested
if [[ "$INCLUDE_HIDDEN" == true ]]; then
    RG_CMD+=("--hidden")
fi

# Add follow links if requested
if [[ "$FOLLOW_LINKS" == true ]]; then
    RG_CMD+=("--follow")
fi

# Add stats if requested
if [[ "$SHOW_STATS" == true ]]; then
    RG_CMD+=("--stats")
fi

# Add directory
RG_CMD+=("$DIRECTORY")

# Print search info
echo "Searching for '$PATTERN' in $DIRECTORY..." >&2
if [[ -n "$BEFORE_LINES" && -n "$AFTER_LINES" ]]; then
    echo "Context: $BEFORE_LINES lines before, $AFTER_LINES lines after" >&2
elif [[ -n "$BEFORE_LINES" ]]; then
    echo "Context: $BEFORE_LINES lines before" >&2
elif [[ -n "$AFTER_LINES" ]]; then
    echo "Context: $AFTER_LINES lines after" >&2
else
    echo "Context: $CONTEXT_LINES lines around matches" >&2
fi

if [[ -n "$FILE_TYPE" ]]; then
    echo "File type: $FILE_TYPE" >&2
fi

echo "" >&2

# Execute the command
exec "${RG_CMD[@]}"