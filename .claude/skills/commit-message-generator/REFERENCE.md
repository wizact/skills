# Commit Message Reference Guide

This reference provides comprehensive guidelines for creating meaningful commit messages based on Conventional Commits specification and git best practices.

## Table of Contents

1. [Format Specification](#format-specification)
2. [Commit Types](#commit-types)
3. [Scopes](#scopes)
4. [Formatting Rules](#formatting-rules)
5. [Examples Gallery](#examples-gallery)
6. [Common Patterns](#common-patterns)
7. [Anti-Patterns](#anti-patterns)
8. [Tools and Automation](#tools-and-automation)
9. [Troubleshooting](#troubleshooting)

## Format Specification

### Basic Structure
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Components Explained

#### Type (Required)
The commit type communicates the intent of the change:
- Must be lowercase
- Followed by optional scope in parentheses
- Followed by colon and space

#### Scope (Optional)
Provides additional context about what part of the codebase was affected:
- Enclosed in parentheses
- Should be a noun describing a section of the codebase
- Examples: `auth`, `parser`, `api`, `ui`, `database`

#### Description (Required)
A brief summary of the change:
- Immediately follows the colon and space
- Lowercase first letter
- Imperative mood (command form)
- No period at the end
- Maximum 50 characters (including type and scope)

#### Body (Optional)
Additional details about the change:
- Separated from description by blank line
- Wrapped at 72 characters
- Explains what and why, not how
- Can include multiple paragraphs

#### Footer (Optional)
Metadata about the commit:
- Separated from body by blank line
- Used for breaking changes, issue references, co-authors
- Format: `<token>: <value>` or `<token> <value>`

## Commit Types

### Primary Types

#### `feat` - New Features
Introduces new functionality to the codebase.
- Correlates with MINOR in semantic versioning
- User-facing functionality
- New capabilities or enhancements

**Examples:**
```
feat: add user authentication system
feat(api): implement GraphQL subscription support
feat(ui): add dark mode toggle
```

#### `fix` - Bug Fixes
Patches a bug in the codebase.
- Correlates with PATCH in semantic versioning
- Resolves issues or errors
- Corrects unexpected behavior

**Examples:**
```
fix: resolve memory leak in image processing
fix(auth): handle expired token edge case
fix(ui): prevent button double-click submission
```

### Additional Types

#### `docs` - Documentation
Documentation only changes.
- README updates
- Code comments
- API documentation
- User guides

**Examples:**
```
docs: update installation instructions
docs(api): add authentication examples
docs: fix typos in contributing guide
```

#### `style` - Code Style
Changes that don't affect code meaning.
- Formatting, whitespace, semicolons
- Linting fixes
- Code organization without logic changes

**Examples:**
```
style: format code according to prettier rules
style(components): organize imports alphabetically
style: remove trailing whitespace
```

#### `refactor` - Code Refactoring
Code changes that neither fix bugs nor add features.
- Improving code structure
- Performance optimizations without user-visible changes
- Code cleanup and organization

**Examples:**
```
refactor: extract validation logic into utils
refactor(parser): simplify token processing algorithm
refactor: consolidate duplicate error handling
```

#### `perf` - Performance Improvements
Changes that improve performance.
- Optimization without changing functionality
- Reducing resource usage
- Speed improvements

**Examples:**
```
perf: optimize database query performance
perf(images): implement lazy loading for gallery
perf: reduce bundle size by 15%
```

#### `test` - Tests
Adding or updating tests.
- Unit tests, integration tests
- Test utilities and fixtures
- Test configuration

**Examples:**
```
test: add unit tests for user service
test(api): add integration tests for auth endpoints
test: increase coverage for validation utils
```

#### `build` - Build System
Changes affecting the build system or dependencies.
- Webpack, rollup, npm scripts
- Package.json updates
- CI/CD configuration

**Examples:**
```
build: update webpack configuration for production
build: upgrade dependencies to latest versions
build(docker): optimize container size
```

#### `ci` - Continuous Integration
CI/CD configuration and scripts.
- GitHub Actions, Jenkins, Travis
- Deployment scripts
- Testing pipelines

**Examples:**
```
ci: add automated testing workflow
ci: configure deploy preview for pull requests
ci(github): update node version in workflow
```

#### `chore` - Maintenance
Other changes that don't modify source or test files.
- Development tools
- Configuration updates
- Maintenance tasks

**Examples:**
```
chore: update .gitignore patterns
chore: configure eslint rules
chore(deps): bump lodash from 4.17.20 to 4.17.21
```

## Scopes

### Choosing Appropriate Scopes

Scopes should be:
- **Specific enough** to be meaningful
- **General enough** to be reusable
- **Consistent** across the project
- **Short** and memorable

### Common Scope Patterns

#### By Architecture Layer
```
feat(api): add new endpoint
feat(ui): update button styles
feat(database): add migration for users table
feat(auth): implement JWT token refresh
```

#### By Feature/Module
```
fix(user-profile): resolve avatar upload issue
feat(shopping-cart): add item quantity controls
docs(payment): update integration guide
```

#### By File/Directory
```
style(src/components): format React components
test(utils/validation): add edge case tests
refactor(lib/parser): simplify token handling
```

### When to Omit Scope

- Changes affect multiple areas equally
- Scope would be too broad to be useful
- Project is small and scopes add little value
- Change is global (affecting entire codebase)

## Formatting Rules

### Subject Line

#### Length Constraints
- **Ideal**: 50 characters or less (including type and scope)
- **Maximum**: 72 characters (hard limit for readability)
- **Minimum**: Descriptive enough to understand the change

#### Writing Style
- **Mood**: Imperative (command form)
  - ✅ "add user authentication"
  - ❌ "added user authentication" or "adds user authentication"
- **Case**: Lowercase after the colon
  - ✅ `feat: add new feature`
  - ❌ `feat: Add new feature`
- **Punctuation**: No period at the end
  - ✅ `fix: resolve memory leak`
  - ❌ `fix: resolve memory leak.`

#### Clarity Guidelines
- Be specific about what changed
- Avoid vague terms ("fix stuff", "update code")
- Focus on the most significant change
- Use active voice

### Body

#### When to Include a Body
- **Complex changes** that need explanation
- **Breaking changes** requiring migration notes
- **Bug fixes** that need context about the issue
- **Design decisions** that benefit from justification

#### Formatting Rules
- **Separation**: Always include blank line between subject and body
- **Line length**: Wrap at 72 characters
- **Paragraphs**: Use blank lines to separate paragraphs
- **Lists**: Use bullet points or numbered lists when appropriate

#### Content Guidelines
- Explain **what** changed and **why**
- Don't explain **how** (code does that)
- Provide context for future developers
- Include relevant background information

### Footer

#### Breaking Changes
```
BREAKING CHANGE: <description of the breaking change>
```

#### Issue References
```
Fixes #123
Closes #456
Resolves #789
Related to #101112
```

#### Co-authorship
```
Co-authored-by: John Doe <john@example.com>
Co-authored-by: Jane Smith <jane@example.com>
```

## Examples Gallery

### Simple Changes

#### Basic Feature
```
feat: add search functionality
```

#### Simple Bug Fix
```
fix: prevent crash on empty input
```

#### Documentation Update
```
docs: update API endpoint documentation
```

### Complex Changes

#### Feature with Context
```
feat(auth): implement two-factor authentication

Add support for TOTP-based 2FA using authenticator apps.
Users can enable 2FA in their profile settings and are required
to provide a 6-digit code during login.

- Add TOTP secret generation and verification
- Create 2FA setup and verification UI components
- Update login flow to handle 2FA requirements
- Add backup codes for account recovery

Closes #234
```

#### Bug Fix with Analysis
```
fix(parser): handle malformed JSON responses gracefully

Previously, the parser would crash when receiving invalid JSON
from external APIs, causing the entire request to fail.

Now catches JSON parsing errors and returns a meaningful error
message to the user while logging the raw response for debugging.

The fix maintains backward compatibility and doesn't change the
API interface.

Fixes #567
Related to #890
```

#### Breaking Change
```
feat(api)!: restructure user endpoints for consistency

Consolidate user-related endpoints under /api/v2/users/ prefix
and standardize response formats across all user operations.

This change improves API consistency and makes it easier for
clients to integrate with the user management system.

BREAKING CHANGE: User endpoints moved from /api/users/ to /api/v2/users/.
Update all client applications to use the new endpoint structure.

Migration guide: https://docs.example.com/api/v2-migration

Closes #123
```

### Multi-File Changes

#### Refactoring Across Components
```
refactor: extract common validation logic

Move shared validation functions from individual components
to a centralized validation utility module. This reduces
code duplication and makes validation logic easier to maintain.

Updated components:
- UserForm, ProductForm, OrderForm
- Updated tests to use new validation utilities
- Added comprehensive test coverage for validation module

No functional changes to validation behavior.
```

#### Build System Update
```
build: upgrade webpack and related dependencies

Update webpack from v4 to v5 and migrate configuration to
support new features and improved tree shaking.

- Webpack 4.46.0 → 5.88.0
- webpack-cli 3.3.12 → 5.1.4
- Update plugins for webpack 5 compatibility
- Migrate deprecated configuration options

Build time reduced by ~30% and bundle size decreased by 12%.

Closes #456
```

## Common Patterns

### Feature Development
```
feat(module): add basic functionality
feat(module): enhance with advanced options
test(module): add comprehensive test suite
docs(module): add usage examples and API docs
```

### Bug Fixing Workflow
```
fix(component): resolve immediate crash issue
test(component): add regression tests
refactor(component): improve error handling
```

### Release Preparation
```
chore: bump version to 2.1.0
build: update dependencies for security patches
ci: add automated release workflow
docs: update changelog for v2.1.0
```

### Dependency Management
```
build(deps): upgrade react from 17.0.2 to 18.2.0
build(deps-dev): bump jest from 27.5.1 to 29.5.0
chore(deps): update package-lock.json
```

## Anti-Patterns

### Avoid These Commit Messages

#### Too Vague
```
❌ fix: bug fix
❌ feat: new stuff
❌ update: various updates
❌ chore: cleanup
```

**Better:**
```
✅ fix(auth): resolve token expiration handling
✅ feat(search): add fuzzy matching algorithm
✅ refactor(utils): optimize string processing functions
✅ chore(deps): update lodash to fix security vulnerability
```

#### Wrong Tense
```
❌ feat: added user registration
❌ fix: fixed memory leak
❌ docs: updated installation guide
```

**Better:**
```
✅ feat: add user registration
✅ fix: resolve memory leak
✅ docs: update installation guide
```

#### Too Long Subject
```
❌ feat: add a comprehensive user authentication system with OAuth2 support, password reset functionality, and email verification
```

**Better:**
```
✅ feat(auth): add comprehensive authentication system

Implement OAuth2, password reset, and email verification.
Supports Google, GitHub, and email/password login methods.

Closes #123
```

#### Missing Context
```
❌ fix: null pointer exception
```

**Better:**
```
✅ fix(user-service): prevent null pointer in profile update

Add null checks before accessing user.profile.settings
to prevent crashes when profile is incomplete.

Fixes #456
```

#### Mixed Concerns
```
❌ feat: add search feature and fix login bug and update docs
```

**Better (separate commits):**
```
✅ feat(search): add full-text search functionality
✅ fix(auth): resolve login timeout issue
✅ docs: update search API documentation
```

## Tools and Automation

### Commit Message Validation

#### commitlint
```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js
```

#### Git Hooks with Husky
```bash
npm install --save-dev husky
npx husky add .husky/commit-msg 'npx commitlint --edit $1'
```

### Interactive Commit Tools

#### Commitizen
```bash
npm install -g commitizen cz-conventional-changelog
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
```

Usage: `git cz` instead of `git commit`

### Automated Changelog Generation

#### standard-version
```bash
npm install --save-dev standard-version
```

Generates changelog and version bumps based on commit messages.

## Troubleshooting

### Common Issues

#### "My commit message is too long"
**Solution:** Break into subject and body
```
feat(api): add user management endpoints

Implement CRUD operations for user accounts including
creation, retrieval, updates, and soft deletion.

Includes input validation, error handling, and
comprehensive test coverage.
```

#### "I have multiple unrelated changes"
**Solution:** Split into separate commits
```bash
# Stage related files separately
git add auth/
git commit -m "feat(auth): add OAuth2 login support"

git add tests/
git commit -m "test(auth): add OAuth2 integration tests"
```

#### "I don't know which type to use"
**Decision tree:**
1. Does it add new functionality? → `feat`
2. Does it fix a bug? → `fix`
3. Does it only change documentation? → `docs`
4. Does it only change formatting/style? → `style`
5. Does it restructure without changing behavior? → `refactor`
6. Does it improve performance? → `perf`
7. Does it only affect tests? → `test`
8. Does it affect build/dependencies? → `build`
9. Does it affect CI/CD? → `ci`
10. Everything else → `chore`

#### "Breaking change but not a feat or fix"
**Solution:** Add `!` to any type
```
refactor(api)!: restructure response format

BREAKING CHANGE: Response format changed from array to object
```

### Best Practices Checklist

Before committing, verify:
- [ ] Subject line under 50 characters
- [ ] Imperative mood in description
- [ ] Type accurately reflects the change
- [ ] Scope is appropriate and consistent
- [ ] Body explains what and why (if needed)
- [ ] Breaking changes are documented
- [ ] Issues are referenced
- [ ] No unrelated changes included
- [ ] Code builds and tests pass

### Project-Specific Adaptations

#### Customizing for Your Team
1. **Define scope conventions** for your project structure
2. **Establish breaking change policies**
3. **Create commit message templates** for common patterns
4. **Set up automated validation** with appropriate rules
5. **Document exceptions** for your specific needs

#### Example Team Guidelines
```markdown
## Our Commit Conventions

### Scopes
- `frontend`: React components and UI
- `backend`: API and server logic
- `mobile`: React Native app
- `shared`: Code used by multiple platforms
- `infra`: Infrastructure and deployment

### Breaking Changes
- Always include migration guide
- Bump major version immediately
- Announce in team Slack channel

### Issue References
- Always reference Jira ticket: `Fixes ABC-123`
- Use GitHub issues for bugs: `Fixes #456`
```

Remember: These guidelines should serve your team's needs. Adapt them as necessary while maintaining consistency and clarity in your commit history.