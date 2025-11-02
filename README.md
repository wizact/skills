# Claude Skills Collection

A curated collection of reusable Claude Skills designed to extend Claude Code capabilities and automate common workflows. These skills help avoid reinventing the wheel across different repositories by providing pre-built automation tools.

## Purpose

This repository contains my most useful and shareable Claude Skills that can be integrated into any project to enhance productivity and automation. Rather than recreating the same functionality repeatedly, these skills provide ready-to-use tools that extend Claude's system capabilities.

## Target Audience

- **Claude Code users** looking to extend their workflow capabilities
- **Anyone using Claude for automation and productivity** improvements

## Prerequisites

Before using these skills, ensure you have the following installed:

- **Shell environment** (POSIX-compatible systems only)
- **Python 3.1+**
- **Node.js**
- **Go (Golang)**
- **Claude Code** (required for skill execution)

> **Note:** Installation scripts for dependencies will be provided and updated as the collection grows.

## Installation

### Recommended Method: Clone + Symlink

#### Step 1: Clone the Repository
First, clone this repository to a central location on your machine:

```bash
# Clone to a central location (e.g., your home directory)
cd ~
git clone https://github.com/wizact/skills.git wizact-skills
```

#### Step 2: Create Symbolic Links

##### Project-Level Installation
To make skills available for a specific project:

```bash
# Navigate to your project root
cd /path/to/your/project

# Create the skills directory if it doesn't exist
mkdir -p .claude/skills

# Create symbolic links for each skill you want to use
ln -s ~/wizact-skills/src/skill-name-1 .claude/skills/skill-name-1
ln -s ~/wizact-skills/src/skill-name-2 .claude/skills/skill-name-2

# Or link all skills at once
for skill in ~/wizact-skills/src/*/; do
    skill_name=$(basename "$skill")
    ln -s "$skill" ".claude/skills/$skill_name"
done
```

##### User-Level Installation
To make skills available across all your projects:

```bash
# Create the user-level skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Create symbolic links for each skill you want to use
ln -s ~/wizact-skills/src/skill-name-1 ~/.claude/skills/skill-name-1
ln -s ~/wizact-skills/src/skill-name-2 ~/.claude/skills/skill-name-2

# Or link all skills at once
for skill in ~/wizact-skills/src/*/; do
    skill_name=$(basename "$skill")
    ln -s "$skill" "$HOME/.claude/skills/$skill_name"
done
```

#### Updating Skills
To get the latest skills and updates:

```bash
# Navigate to the cloned repository
cd ~/wizact-skills

# Pull latest changes
git pull origin main

# The symbolic links will automatically point to the updated skills
```

#### Removing Skills
To remove skills:

```bash
# Remove individual skill symlinks
rm .claude/skills/skill-name-1  # Project-level
rm ~/.claude/skills/skill-name-1  # User-level

# Or remove all wizact skills
find .claude/skills -type l -exec sh -c 'readlink "$1" | grep -q wizact-skills' _ {} \; -delete  # Project-level
find ~/.claude/skills -type l -exec sh -c 'readlink "$1" | grep -q wizact-skills' _ {} \; -delete  # User-level

# Optionally remove the cloned repository
rm -rf ~/wizact-skills
```

### Alternative Method: Copy and Paste

You can also manually copy individual skills:

1. Browse the `src/` directory to find the skill you need
2. Copy the entire skill folder (e.g., `src/my-skill-name/`)
3. Paste it into your local skills directory:
   - Project-level: `.claude/skills/`
   - User-level: `~/.claude/skills/`

## Repository Structure

Skills are organized under the `src/` directory, with each skill in its own subfolder:

```
src/
├── skill-name-1/
│   ├── SKILL.md          # Main skill definition (required)
│   ├── FORMS.md          # Optional forms definition
│   ├── REFERENCE.md      # Optional reference materials
│   └── scripts/          # Optional supporting scripts
│       ├── setup.sh
│       ├── helper.py
│       └── tool.go
└── skill-name-2/
    ├── SKILL.md
    └── ...
```

Each skill follows the Claude Skills standard structure:
- **SKILL.md**: Contains the skill instructions and YAML frontmatter with name and description
- **Supporting files**: Optional scripts, forms, and reference materials as needed

## Technologies Used

- **Markdown**: Primary format for skill definitions
- **Shell scripts**: System automation and setup
- **Python**: Data processing and advanced automation
- **Go**: Performance-critical tools and utilities

## Disclaimer

⚠️ **Use at Your Own Risk**: This collection is provided as-is without any guarantees. Skills are designed for automation and productivity but should be reviewed and tested in your specific environment before use.

## Contributing

Please see our [Contributing Guidelines](./.github/CONTRIBUTING.md) for details on how to contribute to this project.

## License

[License](./LICENSE)

---

*This repository aims to make Claude-powered automation more accessible and reusable across projects.*