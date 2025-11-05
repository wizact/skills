Generate meaningful git commit messages following Conventional Commits and git best practices.

When I use `/commit-message`, I want you to:

1. **Analyze the current git state**:
   - Run `git status` to see staged and unstaged changes
   - Run `git diff --cached` to examine staged changes in detail
   - Run `git diff` to see unstaged changes (if any)

2. **Generate a structured commit message** using Conventional Commits format:
   - Choose appropriate type: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`
   - Add scope when helpful (e.g., `auth`, `api`, `ui`, `database`)
   - Write clear, imperative description under 50 characters
   - Include body and footer when needed for context

3. **Follow formatting best practices**:
   - Use imperative mood ("add" not "added")
   - Keep subject line under 50 characters
   - Wrap body at 72 characters
   - Include issue references (`Fixes #123`)
   - Document breaking changes (`BREAKING CHANGE:`)

4. **Provide explanation** of type and scope choices

5. **Offer alternatives** and allow refinement

Example usage:
- `/commit-message` - Analyze current staged changes and generate commit message
- `/commit-message --help` - Show detailed formatting guidelines and examples

Always ensure commits are atomic (one logical change) and provide meaningful context for future developers.

## Key Commit Types:
- **feat**: New features or functionality
- **fix**: Bug fixes
- **docs**: Documentation changes only
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code restructuring without changing functionality
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Build system or dependency changes
- **ci**: CI/CD configuration changes
- **chore**: Maintenance tasks, tooling

## Format:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Notes
- Do not add the following message to the commit message:
```
 🤖 Generated with [Claude Code](https://claude.com/claude-code)
 ```