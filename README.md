# Claude Code Extensions

A collection of reusable agents, skills, and commands for Claude Code to automate workflows and extend capabilities.

## Purpose

This repository provides pre-built Claude Code extensions that can be integrated into any project. These extensions help avoid recreating the same functionality across different repositories by offering ready-to-use automation tools.

## Installation

```bash
# Clone the repository
git clone https://github.com/wizact/dotclaude.git ~/dotclaude

# Navigate to the project directory
cd ~/dotclaude/

# Run the setup script to create symlinks
./setup.sh
```

The setup script automatically creates symlinks in your global Claude directories:
- `~/.claude/agents/`
- `~/.claude/skills/`
- `~/.claude/commands/`

## What's Included

### Agents

**specbuilder**
- Creates complete feature/bug specifications from GitHub issues, PRs, or user prompts
- Generates three documents: requirements.md (user stories + EARS notation), design.md (technical architecture), and tasks.md (trackable work items)
- Use when planning features or need detailed specifications
- Dependencies: github mcp, context7 mcp, and the folder structure that can be set up using `/setup-context-docs`

### Skills

**ripgrep-search**
- Ultra-fast text search using ripgrep with advanced regex, multiline, and filtering capabilities
- Provides commands for code search, multiline search, context search, log search, search & replace, and search statistics

**fd-search**
- Fast file system search using fd as a replacement for find command
- Includes commands for finding by extension, large files, recent files, empty files, and temp files

### Commands

**commit-message**
- Generates meaningful git commit messages following Conventional Commits and best practices
- Analyzes staged changes and creates structured commit messages

**search-code**
- Smart code pattern search with automatic filtering
- Wraps ripgrep-search skill for convenient code exploration

**setup-context-docs**
- Sets up Context-Driven Development documentation structure
- Creates standard directories and templates for project documentation
