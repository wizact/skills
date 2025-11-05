#! /bin/bash

global_skills_dir="$HOME/.claude/skills"
global_commands_dir="$HOME/.claude/commands"

skills=($(ls -d ./.claude/skills/*/ 2>/dev/null))
commands=($(ls -f ./.claude/commands/* 2>/dev/null))

if [ ! -d "$global_skills_dir" ]; then
    mkdir -p "$global_skills_dir"
fi
for skill in "${skills[@]}"; do
    echo "Setting up skill in folder: $(realpath "$skill")"
    [ -d "$skill" ] || continue # skip non-directories

    basename=$(basename "$skill")

    skill_dir=$(realpath "$global_skills_dir/$basename")
    if [ ! -e "$skill_dir" ]; then
        echo "Skill $basename not found in global skills directory. Creating symlink."
        ln -s "$(realpath "$skill")" "$skill_dir" || echo "Failed to create symlink for $basename"
    else
        echo "Skill $basename already exists in global skills directory. Skipping symlink creation."
    fi
done

if [ ! -d "$global_commands_dir" ]; then
    mkdir -p "$global_commands_dir"
fi

for command in "${commands[@]}"; do
    echo "Setting up command in folder: $(realpath "$command")"
    basename=$(basename "$command")

    command_path="$global_commands_dir/$basename"
    if [ ! -e "$command_path" ]; then
        echo "Command $basename not found in global commands directory. Creating symlink."
        ln -s "$(realpath "$command")" "$command_path" || echo "Failed to create symlink for $basename"
    else
        echo "Command $basename already exists in global commands directory. Skipping symlink creation."
    fi
done
